--------------------------------------------------------
--  DDL for Package Body FND_LOG_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOG_SUMMARY" as
/* $Header: AFUTLGSB.pls 115.0 2004/03/09 02:24:54 kkapur noship $ */


/* This routine is used as a concurrent program.  */
/* Nobody besides the concurrent manager should call it. */
procedure summarize_rows is
  l_count number := 0;
  begin
    select count(*) into l_count from  FND_LOG_MESSAGES;
    fnd_conc_summarizer.insert_row('FND_LOG_MESSAGES', l_count);

    select count(*) into l_count from  FND_LOG_TRANSACTION_CONTEXT;
    fnd_conc_summarizer.insert_row('FND_LOG_TRANSACTION_CONTEXT', l_count);

    select count(*) into l_count from  FND_LOG_ATTACHMENTS;
    fnd_conc_summarizer.insert_row('FND_LOG_ATTACHMENTS', l_count);

    select count(*) into l_count from  FND_LOG_METRICS;
    fnd_conc_summarizer.insert_row('FND_LOG_METRICS', l_count);

    select count(*) into l_count from  FND_LOG_EXCEPTIONS;
    fnd_conc_summarizer.insert_row('FND_LOG_EXCEPTIONS', l_count);

    select count(*) into l_count from  FND_LOG_UNIQUE_EXCEPTIONS;
    fnd_conc_summarizer.insert_row('FND_LOG_UNIQUE_EXCEPTIONS', l_count);

    select count(*) into l_count from  FND_EXCEPTION_NOTES;
    fnd_conc_summarizer.insert_row('FND_EXCEPTION_NOTES', l_count);

    select count(*) into l_count from FND_OAM_BIZEX_SENT_NOTIF;
    fnd_conc_summarizer.insert_row('FND_OAM_BIZEX_SENT_NOTIF', l_count);
  end summarize_rows;

end fnd_log_summary;

/
