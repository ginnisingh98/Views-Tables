--------------------------------------------------------
--  DDL for Package Body PAY_ACTION_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ACTION_PARAMETERS_PKG" as
/* $Header: pyactpar.pkb 120.27.12010000.6 2010/03/01 17:15:36 tclewis ship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : pyactpar.pkb
 Description   : procedures required fofor check to pay_olegislation_rules
 Author        : N.Bristow
 Date Created  : 20-NOV-2003

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 01-MAR-2010  tclewis       115.46    	9380771 Added BALANCES_DISPLAY_ALL_GRES
 28-AUG-2009  tclewis       115.44              Added WAGE_ACCUMULATION_YEAR
 31-JUL-2009  P.Parate      115.43    8560197   Added PPE_BULK_LIMIT, PPE_BATCH_SIZE
 09-SEP-2008  P.Parate      115.42    7279918   Added COST_DATE_PAID
 23-NOV-2006  A.Logue       115.41              Added COST_ZEROS.
 18-JUN-2007  ckesanap      115.38    6065892   Added WAGE_ACCUMULATION_ENABLED
 01-FEB-2007  T.Battoo      115.37              Added PDF_TEMP_DIR
 03-NOV-2006  S.Winton      115.36    5616075   Added EE_ORIG_TERM_RULE_DATE_FUNC.
 24-OCT-2006  A.Logue       115.35              Added PRINT_FILES.
 14-SEP-2006  N.Bristow     115.34              Removed JRE_LIBRARY.
 22-AUG-2006  N.Bristow     115.33              Added REPORT_URL.
 10-AUG-2006  A.Logue       115.32              Added CHANGED_BALANCE_VALUE_CHECK.
 27-JUN-2006  T.Battoo      115.31              Added JRE_LIBRARY.
 09-JUN-2006  A.Logue       115.30    5295555   Added REMOVE_ACT.
 05-MAY-2006  N.Bristow     115.29              Added SET_DATE_EARNED.
 17-APR-2006  A.Handa       115.28    5136327   Added US_SOE_VIEW_FROM_ASG_FP_SCREEN.
 16-MAR-2006  A.Logue       115.27    5092363   Added COST_NO_AT.
 17-FEB-2006  A.Logue       115.26    5044463   Added PAYROLL_WF_NOTIFY_ACTION.
 09-JAN-2006  A.Logue       115.25    4919912   Added INIT_PAY_ARCHIVE.
 21-DEC-2005  T.Habara      115.24    4726174   Added PURGE_SKIP_TERM_ASG.
 09-DEC-2005  M.Reid        115.23    4871533   Added PURGE_TIMEOUT.
 29-NOV-2005  SuSivasu      115.22              Added COST_VAL_SEG.
 22-NOV-2005  A.Logue       115.21              Added TGL_SLA_MODE.
 21-NOV-2005  N.Bristow     115.20              Added PRINTER_MEM_SIZE
                                                and DBC_FILE.
 20-SEP-2005  A.Logue       115.19              Added TGL_GROUP_ID.
 12-SEP-2005  nbristow      115.18              Added JRE_LIBRARY.
 03-Aug-2005  SuSivasu      115.17              Added FREQ_RULE_WHOLE_PERIOD.
 13-JUN-2005  A.Logue       115.16              Added MANY_PROCS_IN_PERIOD.
 09-JUN-2005  A.Logue       115.15              Added PLSQL_PROC_INSERT.
 20-MAY-2005  A.Logue       115.13              Added LAT_BAL_CHECK_MODE.
 17-MAY-2005  A.Logue       115.13              Added RESET_PTO_ACCRUALS.
 10-MAY-2005  A.Logue       115.12              Added HRLEGDEL_SLEEP.
 09-MAY-2005  A.Logue       115.11              Added COST_API_IMODE.
 05-MAY-2005  SuSivasu      115.10              Added ADVANCE_PAY_OFFSET.
 26-APR-2005  A.Logue       115.9               Added US_ADVANCE_EARNING_TEMPLATE.
 04-APR-2005  A.Logue       115.8               Added REV_LAT_BAL.
 17-JAN-2005  A.Logue       115.7               Added RETRO_DELETE,
                                                US_ADVANCED_WAGE_ATTACHMENT.
 12-JAN-2005  A.Logue       115.6               Added ASSIGNMENT_SET_DATE,
                                                TGL_REVB_ACC_DATE.
 11-JAN-2005  A.Logue       115.5               Added SUPPRESS_INSIG_INDIRECTS
 16-DEC-2004  D.Vickers     115.4               Added OLD_LOW_VOLUME
 06-SEP-2004  A.Logue       115.3               Added further Parameters.
 16-AUG-2004  A.Logue       115.2               Added further Parameters.
 30-JUL-2004  N.Bristow     115.1               Added further Parameters.
 24-JUL-2004  N.Bristow     115.0               Created.
*/

function check_act_param(parameter_name varchar2) return boolean is
begin
 if (replace(parameter_name, ' ', '_')
      in
(
'ADD_MAG_REP_FILES',          -- Number of additional mag tape files that can be created
'ADVANCE_PAY_OFFSET',         -- Obsoletes the arrear payroll and allows different offset payrolls for Advance Pay.
'ASSIGNMENT_SET_DATE',        -- Whether date_earned context for assignment sets in eff date
'BAL_BUFFER_SIZE',            -- Size of the Balance Buffer in the Payroll Run
'BEE_INTERVAL_WAIT_SEC',
'BEE_LOCK_INTERVAL_WAIT_SEC',
'BEE_LOCK_MAX_WAIT_SEC',
'BEE_MAX_WAIT_SEC',
'CHANGED_BALANCE_VALUE_CHECK', -- Disable changed balance value check
'CHUNK_SHUFFLE',               -- Randomise the order in which chunks are processed Y/N
'CHUNK_SIZE',                  -- Size of the Chunks (Commit Units)
'COST_BUFFER_SIZE',            -- Size of the Buffer used in Costing
'COST_API_IMODE',              -- Use PL/SQL keyflex API in ID mode
'COST_DATE_PAID',              -- Cost retro element on date paid.
'COST_NO_AT',                  -- Use PL/SQL keyflex API in non-autonomous transaction mode
'COST_PLS_VAL',                -- Use PL/SQL keyflex validation Y/N
'COST_VAL_SEGS',               -- Enable server side validation on the segment.
'COST_ZEROS',                  -- Enable costing of zero value run result values
'COSTBAL',                     -- Use hierarchy in Balance costs too
'DATA_MIGRATOR_MODE',
'DATA_PUMP_DISABLE_CONT_CALC',
'DATA_PUMP_NO_FND_AUDIT',
'DATA_PUMP_NO_LOOKUP_CHECKS',
'DBC_FILE',                    -- DBC File to use to get JAVA connection (used in Dev DBs only
'EE_BUFFER_SIZE',              -- Element Entry Buffer size for Payroll Run
'EE_ORIG_TERM_RULE_DATE_FUNC', -- Use original functionality when deriving EE term rule dates
'FF_MAX_OPEN_CURSORS',
'FREQ_RULE_WHOLE_PERIOD',
'HR_DM_DEBUG_LOG',
'HR_DM_DEBUG_PIPE',
'HR_DU_DEBUG_LOG',
'HR_DU_DEBUG_PIPE',
'HRLEGDEL_SLEEP',              -- Sleep Time for Disable HRMS Access
'INIT_PAY_ARCHIVE',            -- Switch for data corruption workaround in Archive processes
'INTERLOCK',                   -- Use the assignment level interlocking procedures Y/N
'JP_DIM_EXC_REV_FLAG',
'JRE_VERBOSE',                 -- Java Debuging statements
'JRE_XMS',                     -- Java Min Heap Size
'JRE_XMX',                     -- Java Max Heap Size
'JRE_XSS',                     -- Java Min Shared Heap Size
'LAT_BAL_CHECK_MODE',
'LOGGING',                     -- Debug messaging level
'LOG_AREA',                    -- Procedure to Debug
'LOG_ASSIGN_END',              -- Ending Assignment to Debug
'LOG_ASSIGN_START',            -- Starting Assignment to Debug
'LOW_VOLUME',                  -- Use the Rule hint Y/N
'MANY_PROCS_IN_PERIOD',
'MAX_SINGLE_UNDO',             -- Number od assignments that can be rolled back from the form
'MAX_ERRORS_ALLOWED',          -- Maximum number of consecutive errors that can be encoutered before a full failure.
'MAX_ITERATIONS',              -- Maximum number of attempted Runs in iteration
'MESSAGE_NAMES',               -- Switch to only output message names instead of text (for test harness)
'OLD_LOW_VOLUME',              -- Save for rule hint
'PAY_ACTION_PARAMETER_GROUPS', -- Use the new Grouping functionality Y/N
'PAYROLL_WF_NOTIFY_ACTION',    -- Process Workflow wait switch
'PLSQL_PROC_INSERT',           -- Enable/Disable PL/SQL based range processing code
'PPE_BATCH_SIZE',              -- Batch Size for Purge Process Events
'PPE_BULK_LIMIT',               -- Bulk Collect Size for Purge Process Events
'PRINT_FILES',                 -- Use Concurrent request to print files
'PRINTER_MEM_SIZE',            -- Overriding printer memory size in Kbytes
'PROCESS_TIMEOUT',             -- Time in minutes before a process times out.
'PROCOST',                     -- Costing of Proration.
'PUMP_DEBUG_LEVEL',
'PUMP_DT_ENFORCE_FOREIGN_LOCKS',
'PURGE_SKIP_TERM_ASG',         -- Skip Terminated Assignments in Purge Y/N
'PURGE_TIMEOUT',               -- Time in SECONDS before Purge will timeout.
'QUICKPAY_INTERVAL_WAIT_SEC',
'QUICKPAY_MAX_WAIT_SEC',
'RANGE_PERSON_ID',             -- Switch to use person_id in pay_population_ranges
'REMOVE_ACT',                  -- switch to disable the deletion of Reoprt assignment actions
'REPORT_URL',                  -- location used for the report output url.
'RESET_PTO_ACCRUALS',
'RETRO_DELETE',                -- Avoid delete of run results in Retropay
'RETRO_POP_COST_KEYFLEX',      -- Retropay by Element populate cost keyflex_id from orig
'RETRO_RECALC_ALL_COMP',
'REV_LAT_BAL',                 -- Reversals maintain Latest Balances
'RR_BUFFER_SIZE',              -- Run Result Buffer size for the Payroll Run
'RRV_BUFFER_SIZE',             -- Run Result Value size for the Payroll Run
'RUN_XDO',                     -- Run XDO interface
'SET_DATE_EARNED',             -- Set the Date Earned on child processes, Default N
'STD_FILE_NAME',               -- Use the Standard payroll filenaming convention Y/N
'SUPPRESS_INSIG_INDIRECTS',    -- Suppress creation of insignifcant indirect run results
'TAX_CACHE_SIZE',              -- Quantum Cache size
'TAX_CHECK_OVERRIDE',          -- Quantum Override Version checking
'TAX_DATA',                    -- Quantum Location of Taxation files
'TAX_DEBUG_FLAG',              -- Quantum Switch debugging on
'TAX_LIBRARIES',               -- Quantum Location of the Libaries
'TGL_DATE_USED',               -- Date to transfer Run on (date_earned, effective_date)
'TGL_GROUP_ID',                -- Populate group_id in gl_interface
'TGL_REVB_ACC_DATE',           -- Date to transfer Reversals and Balance Adjustments
'TGL_SLA_MODE',                -- Switch for use of Sub Ledger Accounting
'THREADS',                     -- Number of Slave processes to use
'TRACE',                       -- Switch Database Tracing on Y/N
'TRACE_LEVEL',                 -- Trace Level to use
'TRANSGL_THREAD',              -- Switch for Multi-threded TGL version
'TR_BUFFER_SIZE',              -- Taxability Rules Bufffer size for Payroll Run
'US_ADVANCE_EARNING_TEMPLATE', -- Switch for US Earning Element Template
'US_ADVANCED_WAGE_ATTACHMENT', -- Switch for US Wage Attachment functionality
'USER_MESSAGING',              -- Switch User Messaging on Y/N
'UTF8_RESTRICTION_MODE',
'WAGE_ACCUMULATION_ENABLED',   -- Switch for Enhanced Wage Accumulation functionality on Y/N
'WAGE_ACCUMULATION_YEAR',      -- YEAR YYYY on which Wage Accukulation enabled
'JRE_LIBRARY',                 --location of libraries for dynamic linking in c-code
'US_SOE_VIEW_FROM_ASG_FP_SCREEN', -- Switch for US SOE
'PDF_TEMP_DIR',                 -- temp dir for pdf merging
'BALANCES_DISPLAY_ALL_GRES'     -- Bug 	9380771.  Hidden Featre for GSI to
                                -- display all Gre's in the US tax balance
                                -- formas.
)
)
 then
   return true;
 else
  return false;
 end if;
end;

begin
 null;
end;

/
