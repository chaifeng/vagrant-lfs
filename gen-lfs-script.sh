#!/bin/bash

if [[ $# -ne 1 ]]; then
    cat <<HELP
Usage: $0 [lfs|chapter02/file.html]
HELP
    exit 1
fi

function script-filter() {
    local chapter="$1"
    local result_check_function="$(result-filter "${chapter}")"
    declare -a make_check_filter=(cat)
    if [[ -n "$result_check_function" ]]; then
        echo "$result_check_function"
        make_check_filter=(sed -E -e "/\\bmake\\b.+\\b(check|test)\\b/s/^(.+)\$/\\( \\1 || true \\) |\\& checking-result/")
    fi
    case "${chapter}" in
        */introduction.html)
            true
            ;;

        chapter02/hostreqs.html)
            cat
            ;;
        chapter04/creatingminlayout.html)
            echo 'if [[ "$UID" -ne 0 ]]; then sudo "$SHELL" -x "$0" "${current_chapter}"; exit; fi'
            cat
            ;;
        chapter04/addinguser.html)
            echo 'if [[ "$UID" -ne 0 ]]; then sudo "$SHELL" -x "$0" "${current_chapter}"; exit; fi'
            sed -Ee "/^(su|groupadd|useradd|passwd) /s/^/: /" -e "s/\\blfs\\b/vagrant/g"
            ;;
        chapter04/settingenvironment.html)
            sed -E -e "s/^(source|exec) /: \\1 /"
            ;;

        chapter0[56]/*)
            cat
            ;;

        chapter07/changingowner.html|chapter07/kernfs.html)
            echo 'if [[ "$UID" -ne 0 ]]; then sudo "$SHELL" -x "$0" "${current_chapter}"; exit; fi'
            echo 'function mknod() { [[ -e $3 ]] || command mknod "$@"; }'
            echo 'function mount() { command mount | grep -F "$4" || command mount "$@"; }'
            cat
            ;;
        chapter07/chroot.html|chapter08/pkgmgt.html)
            true
            ;;
        chapter0[789]/*|chapter10/*)
            echo "
if [[ \"\${LFS_CHROOT:-}\" != true || ! -d /sources ]]; then
    sudo /usr/sbin/chroot \"$LFS\" /usr/bin/env -i LFS_CHROOT=true \\
                       HOME=/root                         \\
                       TERM=\"\$TERM\"                       \\
                       PS1='(lfs chroot) \\u:\\w\\\$ '        \\
                       PATH=/bin:/usr/bin:/sbin:/usr/sbin \\
                       /bin/bash --login +h -xc \"bash -x /sources/\${0##*/} \${current_chapter}:run\"
    exit
fi
"
            ;;&
        chapter07/createfiles.html)
            sed -e "/^exec /s/^/: /" -e "s/^ln -sv/ln -sfv/"
            ;;
        chapter07/stripping.html)
            echo '[[ -f "$HOME/lfs-temp-tools-10.0.tar.xz" ]] && exit 0'
            sed -e "/^exit/a); ;;&\n\n(all|chapter07|chapter07/stripping.html|chapter07/stripping.html:non-chroot-run) (\n" \
                -e "/^strip /s/\$/ || true/" \
                -e "/^umount /s/^/: /" \
                -e "/^tar /s/.\$/bin usr tools/" \
                -e "/^tar /s,^,ls \"\$HOME\"\\/lfs-temp-tools-10.0\*.tar.xz || ," \
                -e "s/^\(strip\|tar\|test\) /sudo \\1 /"
            ;;
        chapter07/*)
            cat
            ;;

        chapter08/glibc.html)
            sed -e "/^tzselect/s/^/: /" -e "/^ln .\\+<xxx>/s/<xxx>/Etc\\/UTC/"
            ;;
        chapter08/gmp.html)
            sed -Ee "/^(ABI=32|cp) /s/^/: /"
            ;;
        chapter08/shadow.html)
            sed -e "/^passwd /s/^passwd/passwd --delete/"
            ;;
        chapter08/bash.html)
            sed -Ee '/^exec /s/^/: /'
            ;;
        chapter08/autoconf.html)
            sed "/^make check/s/^/: /"
            ;;
        chapter08/groff.html)
            sed -e "s,<paper_size>,A4,"
            ;;
        chapter08/vim.html)
            sed -e "/^vim -c /s/^/: /"
            ;;
        chapter08/util-linux.html)
            sed -e "/^bash /s/^/: /"
            ;;
        chapter08/revisedchroot.html)
            echo "id tester || exit 0"
            sed -e "/^logout/s/^/: /" -e "/^chroot /s/^/: /"
            ;;
        chapter08/*)
            cat
            ;;
        chapter09/symlinks.html)
            sed -e "/^udevadm /s/^/: /" \
                -e "/^bash .\\+init-net-rules\\.sh/s,^,test -f /etc/udev/rules.d/70-persistent-net.rules || ," \
                -e "/83-duplicate_devs\\.rules/,/^EOF\$/s/^/# /"
            ;;
        chapter09/network.html)
            sed -e "s/192\\.168\\.1\\.1\$/192.168.56.1/" \
                -e "s/192\\.168\\.1\\.2\$/192.168.56.200/" \
                -e "s/192\\.168\\.1\\.255/192.168.56.255/" \
                -e "/^domain /s/^/# /" \
                -e "s,<IP address of your primary nameserver>,192.168.56.1," \
                -e "s,<IP address of your secondary nameserver>,1.1.1.1," \
                -e "/<192.168.1.1>/s/^/# /" \
                -e "s,<FQDN>,lfs.local," \
                -e "s,<HOSTNAME>,lfs," \
                -e "s,<lfs>,lfs.local," \
                -e "/^ln .\\+99-default\\.link/s,^,: ," \
                -e "/10-ether0\\.link/,/^EOF\$/s/^/# /" \
                -e "/10-eth-static\\.network/,/^EOF\$/s/^/# /" \
                -e "/^cat .\\+\\/etc\\/resolv\\.conf/,/^EOF\$/s/^/# /" \
                -e "s/<network-device-name>/eth0/" \
                -e "s/<Your Domain Name>/lfs.local/" \
                -e "/^<192.168.0.2>/s/\\[/#\\[/" \
                -e "s/<192.168.0.2>/192.168.56.200/"
            ;;
        chapter09/usage.html)
            sed -e "/^\\(KEYMAP\\|FONT\\|LEGACY\\)/s/^/# /"
            ;;
        chapter09/profile.html)
            sed -e "s/<locale name>/en_US.UTF-8/" -e "s/^\\(export LANG\\)=.\\+/\\1=en_US.UTF-8/"
            ;;
        chapter09/clock.html)
            sed -e "/set-timezone/s/TIMEZONE/UTC/" \
                -e "/disable systemd-timesyncd/s/^/: /" \
                -e "/^timedatectl /s/^/: /"
            ;;
        chapter09/console.html)
            sed -e "s/^/# /"
            ;;
        chapter09/locale.html)
            sed -e "s/<locale name>/en_US.UTF-8/" \
                -e "s/<ll>_<CC>.<charmap><@modifiers>/en_US.UTF-8/" \
                -e "/^localectl /s/^/: /"
            ;;
        chapter09/systemd-custom.html)
            sed -e "/tmp\\.mount/,\$s/^/# /"
            ;;
        chapter09/*)
            cat
            ;;
        chapter10/fstab.html)
            for uuid in /dev/disk/by-id/*; do
                if [[ "$(readlink $uuid)" = */sdb1 ]]; then
                    sdb1="$uuid"
                elif [[ "$(readlink $uuid)" = */sdb5 ]]; then
                    sdb5="$uuid"
                elif [[ "$(readlink $uuid)" = */sdb6 ]]; then
                    sdb6="$uuid"
                fi
            done
            sed -e "/<xxx>/a${sdb1} /boot ext4 defaults 1 1" \
                -e "/<xxx>/s,<xxx>,${sdb5#/dev/}," \
                -e "/<fff>/s,<fff>,ext4," \
                -e "/<yyy>/s,<yyy>,${sdb6#/dev/}," \
                -e "/^hdparm /s/^/# /"
            ;;
        chapter10/kernel.html)
            sed -e "/^make menuconfig/s/menuconfig/defconfig/" \
                -e "/^mount .\\+\\/boot/s/^/: /"
            ;;
        chapter10/grub.html)
            sed -e "/^cd /,/^xorriso /s,^,: ," \
                -e "/^set root/s/=.\\+/=(hd0,msdos1)/" \
                -e "s,sda2,sda5," \
                -e "/^grub-install/s/sda/sdb/" \
                -e "s,/boot/vmlinuz,/vmlinuz," \
                -e "/^menuentry/a\ \ \ \ set root=(hd0,msdos1)"

            ;;
        chapter10/*)
            cat
            ;;
        *)
            true
            ;;
    esac | "${make_check_filter[@]}"
}

function result-filter() (
    local chapter="$1"
    case "${chapter}" in
        chapter08/glibc.html)
            function check() {
                grep "^FAIL:" |
                    sed "/\\(io\\/tst-lchmod\\|misc\\/tst-ttyname\\|nss\\/tst-nss-files-hosts-multi\\|rt\\/tst-cputimer[123]\\|tst-mutex10\|sunrpc\\/tst-udp-timeout\\)/d"
            }
            ;;
        chapter08/gcc.html)
            # Additionally the following tests related to the following files are known to fail with glibc-2.32: asan_test.C, co-ret-17-void-ret-coro.C, pr95519-05-gro.C, pr80166.c.
            function check() {
                grep "^FAIL" |
                    sed -Ee "/(asan_test|co-ret-17-void-ret-coro|pr95519-05-gro|pr80166)\\.[cC]/d" \
                        -e "/\\/numpunct\\/members\\//d" \
                        -e "/\\/time_get\\/get_time\\//d"
            }
            ;;
        chapter08/libtool.html)
            function check() {
                grep -F '64 failed (59 expected failures).' >/dev/null || echo failed
            }
            ;;
        chapter08/xz.html)
            # function check() { :; }
            ;;
        chapter08/zstd.html)
            # function check() { :; }
            ;;
        chapter08/file.html)
            # function check() { :; }
            ;;
        chapter08/readline.html)
            # function check() { :; }
            ;;
        chapter08/m4.html)
            # function check() { :; }
            ;;
        chapter08/bc.html)
            # function check() { :; }
            ;;
        chapter08/flex.html)
            # function check() { :; }
            ;;
        chapter08/binutils.html)
            # function check() { :; }
            ;;
        chapter08/gmp.html)
            # function check() { :; }
            ;;
        chapter08/gperf.html)
            # function check() { :; }
            ;;
        chapter08/expat.html)
            # function check() { :; }
            ;;
        chapter08/inetutils.html)
            # function check() { :; }
            ;;
        chapter08/perl.html)
            # function check() { :; }
            ;;
        chapter08/xml-parser.html)
            # function check() { :; }
            ;;
        chapter08/intltool.html)
            # function check() { :; }
            ;;
        chapter08/autoconf.html)
            # function check() { :; }
            ;;
        chapter08/automake.html)
            # function check() { :; }
            ;;
        chapter08/kmod.html)
            # function check() { :; }
            ;;
        chapter08/libelf.html)
            # function check() { :; }
            ;;
        chapter08/libffi.html)
            # function check() { :; }
            ;;
        chapter08/openssl.html)
            # function check() {
            #     grep "^FAIL" "$log" |
            #         sed -ne "/^Test Summary Report/,/^  Failed test:/p" | sed -e 1,2d -e '$d' | sed -e "/30-test_afalg\\.t/d"
            # }
            ;;
        chapter08/Python.html)
            # function check() { :; }
            ;;
        chapter08/ninja.html)
            # function check() { :; }
            ;;
        chapter08/meson.html)
            # function check() { :; }
            ;;
        chapter08/coreutils.html)
            # function check() { :; }
            ;;
        chapter08/check.html)
            # function check() { :; }
            ;;
        chapter08/diffutils.html)
            # function check() { :; }
            ;;
        chapter08/gawk.html)
            # function check() { :; }
            ;;
        chapter08/findutils.html)
            # function check() { :; }
            ;;
        chapter08/groff.html)
            # function check() { :; }
            ;;
        chapter08/grub.html)
            # function check() { :; }
            ;;
        chapter08/less.html)
            # function check() { :; }
            ;;
        chapter08/gzip.html)
            # function check() { :; }
            ;;
        chapter08/iproute2.html)
            # function check() { :; }
            ;;
        chapter08/kbd.html)
            # function check() { :; }
            ;;
        chapter08/libpipeline.html)
            # function check() { :; }
            ;;
        chapter08/make.html)
            # function check() { :; }
            ;;
        chapter08/patch.html)
            # function check() { :; }
            ;;
        chapter08/man-db.html)
            # function check() { :; }
            ;;
        chapter08/tar.html)
            function check() {
                grep -F FAILED |
                    sed "/store\\/restore/d"
            }
            ;;
        chapter08/texinfo.html)
            # function check() { :; }
            ;;
        chapter08/vim.html)
            # function check() { :; }
            ;;
        chapter08/eudev.html)
            # function check() { :; }
            ;;
        chapter08/procps-ng.html)
            # function check() { :; }
            ;;
        chapter08/util-linux.html)
            # function check() { :; }
            ;;
        chapter08/e2fsprogs.html)
            # function check() { :; }
            ;;
        chapter08/sysklogd.html)
            # function check() { :; }
            ;;
        chapter08/sysvinit.html)
            # function check() { :; }
            ;;
        chapter08/aboutdebug.html)
            # function check() { :; }
            ;;
        chapter08/strippingagain.html)
            # function check() { :; }
            ;;
        chapter08/revisedchroot.html)
            # function check() { :; }
            ;;
        *)
            # function check() { :; }
            ;;
    esac

    if [[ function = "$(type -t check)" ]]; then
        declare -pf check
    fi
)

function unhtml() {
    sed -e "s/<[^>]\\+>//g" -e "s/^<[^>]\\+\$//" -e "s/^[^>]\\+>//" \
        -e 's/\&gt;/>/g' -e 's/\&lt;/</g' -e 's/\&nbsp;/ /g' \
        -e 's/\&amp;/\&/g' \
        -e 's/^[[:blank:]\+]$//'
}

function lfs-code-header() {
    cat <<\FUNCTIONS
#!/bin/bash
set -euo pipefail

function clean() {
    local build_dir
    for dir; do
        build_dir="${LFS:-}/sources/${dir##*/}"
        [[ -d "$build_dir" ]] && rm -rf "$build_dir"
    done
}

function xf() {
    local archive="${LFS:-}/sources/${1##*/}"
    local dir="${LFS:-}/sources/${2##*/}"
    [[ -d "$dir" ]] || mkdir -v "$dir"
    tar --strip-components=1 -C "${dir}" -xf "$archive"
    cd "$dir"
}

function checking-result() {
    local log="lfs-check.log"
    tee "$log"
    local result="$(cat "$log" | check)"
    [[ -z "$result" ]]
}

trap 'echo "${current_chapter}"' EXIT

FUNCTIONS

    cat <<\SCRIPT

## Build Linux From Scratch
chapter="${1:-}"
chapter="${chapter:+chapter}${chapter#*chapter}"
chapter="${chapter%/}"
echo "${chapter:=all}"

for p in ~vagrant/.bash_profile ~vagrant/.bashrc; do
    [[ -f "$p" ]] && source "$p"
done

export LFS="${LFS:-}"
cd "${LFS}/sources"

case "${chapter}" in

SCRIPT
}

function lfs-code-footer() {
    cat <<\SCRIPT

## DONE

(*)
    current_chapter="All done."
;;
esac

echo "===== DONE ======"

SCRIPT
}

function lfs-code() (
    local source="${1}"
    local chapter="chapter${source#*/chapter}"

    local script title chapter_number
    script="$(sed -n "/<pre .\\+\\(userinput\\|install\\|root\\)/,/<\\/pre>/p" "$@" |
        sed -Ee "/<[^>]+\$/N;s/\\n/ /" | sed -Ee "/<[^>]+\$/N;s/\\n/ /" | sed -Ee "/<[^>]+\$/N;s/\\n/ /" |
        unhtml |
        script-filter "${chapter}")"
    [[ -n "${script}" ]] || return 0

    title="$(sed -n "/<title>/,/<\\/title>/p" "${source}" |
        sed -n 2p |
        sed "s/^ \\+//" |
        unhtml)"
    chapter_number="$(printf "%d%02d" "$(cut -d. -f1 <<< "$title")" "$(cut -d. -f2 <<< "$title")")"

    local build_dir build_done
    build_dir="${chapter_number}-${chapter#*/}"
    build_dir="${build_dir%.*}.build"
    #build_done="${chapter//\//_}"
    build_done="${build_dir%.*}.done"

    cat <<TITLE


###################################################################################################
######## ------------------------- $title ---------------------
######## $chapter

(all|${chapter%/*}|${chapter}|${chapter}:*)
    title="${title}"
    current_chapter="${chapter}"; echo "\$current_chapter \$title"
    build_done="\${LFS:-}/sources/${build_done}"
    build_dir="\${LFS:-}/sources/${build_dir}"
    echo -e "\e[31m\${title}\e[0m"
    (
    cd "\${LFS:-}/sources"
    if [[ -f "\${build_done}" ]]; then
        echo -e "\e[33mSkipping ${title}\e[0m"
        exit
    fi

    case "\$chapter" in

TITLE
    shopt -s nullglob

    declare -a file=()
    filename="${chapter##*/}"
    until [[ "${filename}" = "${filename%[.-]*}" ]]; do
        filename="${filename%[.-]*}"
        file=("${LFS}/sources/${filename}"*.{bz2,gz,xz,tgz})
        case "$filename" in
            (tcl)
                file=("${LFS}/sources/${filename}"*-src*.{bz2,gz,xz,tgz})
                ;;
            (xml-parser)
                file=("${LFS}/sources/XML-Parser-"*.{bz2,gz,xz,tgz})
                ;;
            (libelf)
                file=("${LFS}/sources/elfutils"*.{bz2,gz,xz,tgz})
                ;;
            (bootscripts)
                file=("${LFS}/sources/lfs-${filename}"*.{bz2,gz,xz,tgz})
                ;;
            (kernel)
                file=("${LFS}/sources/linux-"*.{bz2,gz,xz,tgz})
                ;;
            (systemd-custom)
                file=()
                break
                ;;
            (systemd)
                file=("${LFS}/sources/systemd-"???.{bz2,tar.gz,xz,tgz})
                ;;
        esac
        if [[ "${#file[@]}" -eq 1 ]]; then
            break
        elif [[ "${#file[@]}" -gt 1 ]]; then
            echo "exit 2 # $chapter ::: " "${file[@]}" >&2
            exit 2
        fi
    done

    if [[ -f "$file" ]]; then
        cat <<SCRIPT
    (all|${chapter%/*}|${chapter}|${chapter}:clean)
    echo -e "\e[31m${title}:clean\e[0m"
    [[ -d "\${build_dir}" ]] && sudo rm -rf "\${build_dir}"
    ;;&
    (all|${chapter%/*}|${chapter}|${chapter}:run|${chapter}:extract)
    echo -e "\e[31m${chapter}:extract\e[0m"
    xf "${file##*/}" "${build_dir}"
    ;;&
SCRIPT
    fi
    cat <<SCRIPT

    (all|${chapter%/*}|${chapter}|${chapter}:run) (
    echo -e "\e[31m${chapter}:run \$(pwd)\e[0m"
    set -x
# #${title} ---------------------------------------------

${script}

# --------------------------------------------------------------------------
    cd \${LFS:-}/sources
    if [[ -n "\${build_dir}" ]] && [[ -d "\${build_dir}" ]]; then
        rm -rf "\${build_dir}" || sudo rm -rf "\${build_dir}"
    fi
    [[ -z "$file" ]] || touch "\${build_done}"
    ); ;;
    esac

); ;;& ##### =========== ${chapter} ${title} ===================================

SCRIPT
)

function lfs-chapter-code() {
    local chapter="$1"
    cat "${chapter}" |
        sed -n "/Table of Content/,/<\\/ul>/p" |
        grep -Eo "[^\"]+\\.html" |
        sed "/introduction\\.html/d" |
        while read -r html; do
            lfs-code "${chapter%/*}/$html"
        done
}

source="${1%/}"
if [[ ! -e "$source" ]]; then
    echo "$source does not exist." >&2
    exit 1
fi
source="$(realpath "$source")"
chapter="chapter${source#*/chapter}"

if [[ -d "$source" && -d "${source}/chapter01" && -f "${source}/chapter01/chapter01.html" ]]; then
    lfs-code-header
    echo "## All files"
    for chapter in "${source}"/chapter??; do
        lfs-chapter-code "${chapter}/${chapter##*/}.html"
    done
    lfs-code-footer
elif [[ -d "$source" && -f "${source}/${source##*/}.html" ]]; then
    lfs-code-header
    lfs-chapter-code "${source}/${source##*/}.html"
    lfs-code-footer
elif [[ -f "$source" && "${chapter}" = chapter??/*.html ]]; then
    lfs-code-header
    lfs-code "$source"
    lfs-code-footer
else
    echo "Unknown $source."
    exit 1
fi
