--------------------------------------------------------
--  DDL for Package Body WIP_LOGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_LOGGER" as
 /* $Header: wipflogb.pls 120.0 2005/05/24 19:13:55 appldev noship $ */

  --package variables
  g_indentLevel NUMBER := 0;
  g_sessionID NUMBER := -1;
  type char_tbl_t is table of varchar2(2000) index by binary_integer;
  g_moduleTbl char_tbl_t;
  --package constants
  g_maxMsgLen NUMBER := 255;
  g_maxIndentLevel NUMBER := 10;
  g_indentOffset NUMBER := 2;
  g_anonModule VARCHAR2(30) := 'wip.plsql.anonymous';

  procedure init(x_returnStatus     out NOCOPY VARCHAR2);

  procedure write(p_logLevel IN NUMBER,
                  p_msg IN VARCHAR2,
                  x_returnStatus out NOCOPY VARCHAR2);

  procedure log(p_msg           IN VARCHAR2,
                x_returnStatus out NOCOPY VARCHAR2) is
  begin
    write(p_logLevel => wip_constants.full_logging,
          p_msg => p_msg,
          x_returnStatus => x_returnStatus);
  end log;

  procedure entryPoint(p_procName      IN VARCHAR2,
                       p_params        IN param_tbl_t,
                       x_returnStatus out NOCOPY VARCHAR2) is
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    g_indentLevel := least(g_indentLevel + 1, g_maxIndentLevel);

    g_moduleTbl(nvl(g_moduleTbl.last, 0) + 1) := 'wip.plsql.' || p_procName;

    write(p_msg          => '[begin ' || p_procName || ']',
          p_logLevel     => wip_constants.full_logging,
          x_returnStatus => x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
       raise fnd_api.g_exc_unexpected_error;
    end if;
    for i in 1..p_params.count loop
      write(p_msg          => '  ' || p_params(i).paramName || ': ' || p_params(i).paramValue,
            p_logLevel     => wip_constants.full_logging,
            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
         raise fnd_api.g_exc_unexpected_error;
      end if;
    end loop;

  exception
    when others then
      null;--write() will set all return values properly
  end entryPoint;

  procedure exitPoint(p_procName          IN VARCHAR2,
                      p_procReturnStatus  IN VARCHAR2,
                      p_msg               IN VARCHAR2,
                      x_returnStatus     out NOCOPY VARCHAR2) is
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    write(p_msg          => '[end ' || p_procName || ']',
          p_logLevel     => wip_constants.full_logging,
          x_returnStatus => x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    write(p_msg          => '  return status: ' || p_procReturnStatus,
          p_logLevel     => wip_constants.full_logging,
          x_returnStatus => x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    write(p_msg          => '  info: ' || p_msg,
          p_logLevel     => wip_constants.full_logging,
          x_returnStatus => x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --this if should always be true
    if(g_moduleTbl.last is not null) then
      g_moduleTbl.delete(g_moduleTbl.last);
    end if;
    g_indentLevel := greatest(g_indentLevel - 1, 0);
  exception
    when others then
      --write() will set all return parameters correctly
      g_indentLevel := greatest(g_indentLevel - 1, 0);
  end exitPoint;

  procedure cleanUp(x_returnStatus     out NOCOPY VARCHAR2) is
  begin
    write(p_msg          => 'Session ' || g_sessionID || ': ended on ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'),
          p_logLevel     => wip_constants.full_logging,
          x_returnStatus => x_returnStatus);
    g_sessionID := -1;
    g_indentLevel := 0;
    g_moduleTbl.delete;

    x_returnStatus := fnd_api.g_ret_sts_success;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'wip_logger',
                              p_procedure_name => 'cleanUp',
                              p_error_text     => SQLERRM);
  end cleanUp;

  procedure write(p_logLevel     IN NUMBER,
                  p_msg          IN VARCHAR2,
                  x_returnStatus out NOCOPY VARCHAR2) is
    l_msg VARCHAR2(2000);
    l_module VARCHAR2(2000);
  begin
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if(g_sessionID < 0) then
      init(x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    l_msg := 'Session ' || g_sessionID || ': ';
    l_msg := lpad(l_msg, g_indentLevel * g_indentOffset + length(l_msg), ' ');
    l_msg := l_msg || substr(p_msg, 0, g_maxMsgLen - length(l_msg));
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if(g_moduleTbl.last is null) then
      g_moduleTbl(1) := g_anonModule;
    end if;

    -- to work around GSCC, the call to fnd_log.string needs to pass
    -- accordingly...
    if ( p_logLevel = FND_LOG.LEVEL_STATEMENT AND
         FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT ) then
       fnd_log.string(log_level => FND_LOG.LEVEL_STATEMENT,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    elsif ( p_logLevel = FND_LOG.LEVEL_PROCEDURE AND
            FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE ) then
       fnd_log.string(log_level => FND_LOG.LEVEL_PROCEDURE,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    elsif ( p_logLevel = FND_LOG.LEVEL_EVENT AND
            FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT ) then
       fnd_log.string(log_level => FND_LOG.LEVEL_EVENT,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    elsif ( p_logLevel = FND_LOG.LEVEL_EXCEPTION AND
            FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION ) then
       fnd_log.string(log_level => FND_LOG.LEVEL_EXCEPTION,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    elsif ( p_logLevel = FND_LOG.LEVEL_ERROR AND
            FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR ) then
       fnd_log.string(log_level => FND_LOG.LEVEL_ERROR,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    elsif ( p_logLevel = FND_LOG.LEVEL_UNEXPECTED AND
            FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED ) then
        fnd_log.string(log_level => FND_LOG.LEVEL_UNEXPECTED,
                      module => g_moduleTbl(g_moduleTbl.last),
                      message => l_msg);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'wip_logger',
                              p_procedure_name => 'write',
                              p_error_text     => SQLERRM);
  end write;

  procedure init(x_returnStatus     out NOCOPY VARCHAR2) is
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    g_indentLevel := 0;

    if(g_sessionID < 0) then
      select wip_logging_session_s.nextval
        into g_sessionID
        from dual;
    end if;
    write(p_msg => 'Session ' || g_sessionID || ': started on ' || to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS'),
          p_logLevel => wip_constants.trace_logging,
          x_returnStatus => x_returnStatus);
  end init;
end wip_logger;

/
