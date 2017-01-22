FROM nbrown/revealjs:3.4.0-onbuild

# Provide image labels in support of the Label Schema (http://label-schema.org)
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.license="MIT" \
      org.label-schema.version="0.1.0" \
      org.label-schema.url="https://github.com/solidnerd/slides." \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/solidnerd/slides.git" \
      org.label-schema.vcs-type="Git"



