#
# Seccomp Library Python Bindings
#
# Copyright (c) 2012,2013 Red Hat <pmoore@redhat.com>
# Author: Paul Moore <paul@paul-moore.com>
#

#
# This library is free software; you can redistribute it and/or modify it
# under the terms of version 2.1 of the GNU Lesser General Public License as
# published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, see <http://www.gnu.org/licenses>.
#

from libc.stdint cimport int8_t, int16_t, int32_t, int64_t
from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t

cdef extern from "seccomp.h":

    cdef struct scmp_version:
        unsigned int major
        unsigned int minor
        unsigned int micro

    ctypedef void* scmp_filter_ctx

    cdef enum:
        SCMP_ARCH_NATIVE
        SCMP_ARCH_X86
        SCMP_ARCH_X86_64
        SCMP_ARCH_X32
        SCMP_ARCH_ARM
        SCMP_ARCH_AARCH64
        SCMP_ARCH_MIPS
        SCMP_ARCH_MIPS64
        SCMP_ARCH_MIPS64N32
        SCMP_ARCH_MIPSEL
        SCMP_ARCH_MIPSEL64
        SCMP_ARCH_MIPSEL64N32
        SCMP_ARCH_PARISC
        SCMP_ARCH_PARISC64
        SCMP_ARCH_PPC
        SCMP_ARCH_PPC64
        SCMP_ARCH_PPC64LE
        SCMP_ARCH_S390
        SCMP_ARCH_S390X
        SCMP_ARCH_RISCV64

    cdef enum scmp_filter_attr:
        SCMP_FLTATR_ACT_DEFAULT
        SCMP_FLTATR_ACT_BADARCH
        SCMP_FLTATR_CTL_NNP
        SCMP_FLTATR_CTL_TSYNC
        SCMP_FLTATR_API_TSKIP
        SCMP_FLTATR_CTL_LOG
        SCMP_FLTATR_CTL_SSB
        SCMP_FLTATR_CTL_OPTIMIZE
        SCMP_FLTATR_API_SYSRAWRC
        SCMP_FLTATR_CTL_WAITKILL

    cdef enum scmp_compare:
        SCMP_CMP_NE
        SCMP_CMP_LT
        SCMP_CMP_LE
        SCMP_CMP_EQ
        SCMP_CMP_GE
        SCMP_CMP_GT
        SCMP_CMP_MASKED_EQ

    cdef enum:
        SCMP_ACT_KILL_PROCESS
        SCMP_ACT_KILL
        SCMP_ACT_TRAP
        SCMP_ACT_LOG
        SCMP_ACT_ALLOW
        SCMP_ACT_NOTIFY
    unsigned int SCMP_ACT_ERRNO(int errno)
    unsigned int SCMP_ACT_TRACE(int value)

    ctypedef uint64_t scmp_datum_t

    cdef struct scmp_arg_cmp:
        unsigned int arg
        scmp_compare op
        scmp_datum_t datum_a
        scmp_datum_t datum_b

    cdef struct seccomp_data:
        int nr
        uint32_t arch
        uint64_t instruction_pointer
        uint64_t args[6]

    cdef struct seccomp_notif_sizes:
        uint16_t seccomp_notif
        uint16_t seccomp_notif_resp
        uint16_t seccomp_data

    cdef struct seccomp_notif:
        uint64_t id
        uint32_t pid
        uint32_t flags
        seccomp_data data

    cdef struct seccomp_notif_resp:
        uint64_t id
        int64_t val
        int32_t error
        uint32_t flags

    scmp_version *seccomp_version()

    unsigned int seccomp_api_get()
    int seccomp_api_set(unsigned int level)

    scmp_filter_ctx seccomp_init(uint32_t def_action)
    int seccomp_reset(scmp_filter_ctx ctx, uint32_t def_action)
    void seccomp_release(scmp_filter_ctx ctx)

    int seccomp_merge(scmp_filter_ctx ctx_dst, scmp_filter_ctx ctx_src)

    uint32_t seccomp_arch_resolve_name(char *arch_name)
    uint32_t seccomp_arch_native()
    int seccomp_arch_exist(scmp_filter_ctx ctx, int arch_token)
    int seccomp_arch_add(scmp_filter_ctx ctx, int arch_token)
    int seccomp_arch_remove(scmp_filter_ctx ctx, int arch_token)

    int seccomp_load(scmp_filter_ctx ctx)

    int seccomp_attr_get(scmp_filter_ctx ctx,
                         scmp_filter_attr attr, uint32_t* value)
    int seccomp_attr_set(scmp_filter_ctx ctx,
                         scmp_filter_attr attr, uint32_t value)

    char *seccomp_syscall_resolve_num_arch(int arch_token, int num)
    int seccomp_syscall_resolve_name_arch(int arch_token, char *name)
    int seccomp_syscall_resolve_name_rewrite(int arch_token, char *name)
    int seccomp_syscall_resolve_name(char *name)
    int seccomp_syscall_priority(scmp_filter_ctx ctx,
                                 int syscall, uint8_t priority)

    int seccomp_rule_add(scmp_filter_ctx ctx, uint32_t action,
                         int syscall, unsigned int arg_cnt, ...)
    int seccomp_rule_add_array(scmp_filter_ctx ctx,
                               uint32_t action, int syscall,
                               unsigned int arg_cnt,
                               scmp_arg_cmp *arg_array)
    int seccomp_rule_add_exact(scmp_filter_ctx ctx, uint32_t action,
                               int syscall, unsigned int arg_cnt, ...)
    int seccomp_rule_add_exact_array(scmp_filter_ctx ctx,
                                     uint32_t action, int syscall,
                                     unsigned int arg_cnt,
                                     scmp_arg_cmp *arg_array)

    int seccomp_notify_alloc(seccomp_notif **req, seccomp_notif_resp **resp)
    void seccomp_notify_free(seccomp_notif *req, seccomp_notif_resp *resp)
    int seccomp_notify_receive(int fd, seccomp_notif *req)
    int seccomp_notify_respond(int fd, seccomp_notif_resp *resp)
    int seccomp_notify_id_valid(int fd, uint64_t id)
    int seccomp_notify_fd(scmp_filter_ctx ctx)

    int seccomp_export_pfc(scmp_filter_ctx ctx, int fd)
    int seccomp_export_bpf(scmp_filter_ctx ctx, int fd)
    int seccomp_export_bpf_mem(const scmp_filter_ctx ctx, void *buf,
                               size_t *len)

    int seccomp_precompute(const scmp_filter_ctx ctx)

# kate: syntax python;
# kate: indent-mode python; space-indent on; indent-width 4; mixedindent off;
