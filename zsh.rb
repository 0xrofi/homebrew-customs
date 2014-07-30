require 'formula'

class Zsh < Formula
  homepage 'http://www.zsh.org/'
  url 'https://downloads.sourceforge.net/project/zsh/zsh/5.0.5/zsh-5.0.5.tar.bz2'
  mirror 'http://www.zsh.org/pub/zsh-5.0.5.tar.bz2'
  sha1 '75426146bce45ee176d9d50b32f1ced78418ae16'

  depends_on 'gdbm'
  depends_on 'pcre'

  option 'disable-etcdir', 'Disable the reading of Zsh rc files in /etc'

  patch :p1 do
    url "https://gist.githubusercontent.com/0xrofi/ebc46efe72e010b8542f/raw/362b9e46268bfb0b3a3c7212acb89b6868898e40/wcswidth_cjk.diff"
    sha1 "712455affb2be5620d3cff531749a451564bc8ed"
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/0xrofi/567002e18a075de32711/raw/5797bf1dbdf6e62e95501e441a72ebf66cfb0e38/conv_modified_NFD.diff"
    sha1 "f3b1501ce26c46ab1cc431f170ca5e4ab423a0d9"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --enable-locale
      zsh_cv_c_broken_wcwidth=yes
    ]

    if build.include? 'disable-etcdir'
      args << '--disable-etcdir'
    else
      args << '--enable-etcdir=/etc'
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make", "install"
    system "make", "install.info"
  end

  test do
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/helpfiles
    EOS
  end
end
