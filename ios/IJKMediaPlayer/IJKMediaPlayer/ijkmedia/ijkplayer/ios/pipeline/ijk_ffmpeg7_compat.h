/*
 * ijk_ffmpeg7_compat.h
 *
 * Compatibility shims for building ijkplayer's iOS VideoToolbox pipeline against
 * FFmpeg 7. FFmpeg 5–7 removed the standalone Annex-B<->AVCC helpers
 * (ff_avc_parse_nal_units / ff_avc_find_startcode) from libavformat, and
 * AV_PKT_FLAG_NEW_SEG is an ijk/bilibili-fork addition absent from vanilla
 * FFmpeg. Re-provide them locally so the VTB nodes keep working.
 */
#ifndef IJK_FFMPEG7_COMPAT_H
#define IJK_FFMPEG7_COMPAT_H

#include <stdint.h>
#include "libavformat/avio.h"

/* ijkplayer concat flag: "first packet from a source in concat" (0x8000).
 * Vanilla FFmpeg 7 does not define it and never sets that bit, so redefining it
 * here is safe (the ijk concat protocol path is disabled under FFmpeg 7). */
#ifndef AV_PKT_FLAG_NEW_SEG
#define AV_PKT_FLAG_NEW_SEG 0x8000
#endif

static const uint8_t *ijk_avc_find_startcode_internal(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *a = p + 4 - ((intptr_t)p & 3);

    for (end -= 3; p < a && p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }

    for (end -= 3; p < end; p += 4) {
        uint32_t x = *(const uint32_t*)p;
        if ((x - 0x01010101) & (~x) & 0x80808080) { // generic
            if (p[1] == 0) {
                if (p[0] == 0 && p[2] == 1)
                    return p;
                if (p[2] == 0 && p[3] == 1)
                    return p+1;
            }
            if (p[3] == 0) {
                if (p[2] == 0 && p[4] == 1)
                    return p+2;
                if (p[4] == 0 && p[5] == 1)
                    return p+3;
            }
        }
    }

    for (end += 3; p < end; p++) {
        if (p[0] == 0 && p[1] == 0 && p[2] == 1)
            return p;
    }

    return end + 3;
}

static const uint8_t *ijk_avc_find_startcode(const uint8_t *p, const uint8_t *end)
{
    const uint8_t *out = ijk_avc_find_startcode_internal(p, end);
    if (p < out && out < end && !out[-1])
        out--;
    return out;
}

/* Annex-B (start-code delimited) -> AVCC (4-byte length prefixed), written to pb.
 * Restored from the ijk FFmpeg 4.0 libavformat/avc.c (removed in FFmpeg 7). */
static int ff_avc_parse_nal_units(AVIOContext *pb, const uint8_t *buf_in, int size)
{
    const uint8_t *p = buf_in;
    const uint8_t *end = p + size;
    const uint8_t *nal_start, *nal_end;

    size = 0;
    nal_start = ijk_avc_find_startcode(p, end);
    for (;;) {
        while (nal_start < end && !*(nal_start++));
        if (nal_start == end)
            break;

        nal_end = ijk_avc_find_startcode(nal_start, end);
        avio_wb32(pb, (uint32_t)(nal_end - nal_start));
        avio_write(pb, nal_start, (int)(nal_end - nal_start));
        size += 4 + (int)(nal_end - nal_start);
        nal_start = nal_end;
    }
    return size;
}

#endif /* IJK_FFMPEG7_COMPAT_H */
