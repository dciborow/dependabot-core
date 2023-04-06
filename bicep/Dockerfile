FROM ghcr.io/dependabot/dependabot-updater-core

USER root
COPY --chown=dependabot:dependabot bicep/helpers /opt/bicep/helpers
RUN bash /opt/bicep/helpers/build

USER dependabot
COPY --chown=dependabot:dependabot bicep /home/dependabot/bicep
