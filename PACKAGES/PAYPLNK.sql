--------------------------------------------------------
--  DDL for Package PAYPLNK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYPLNK" AUTHID CURRENT_USER as
/* $Header: paylink.pkh 120.0.12010000.1 2008/07/27 21:49:33 appldev ship $ */
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.run_process                                               --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- The main procedure called from the SRS screen, from which the     --
 -- paylink process is triggered for a particular batch.              --
 -- The success status of the process, or not, as the case maybe,     --
 -- is returned back to the SRS screen.                               --
 -----------------------------------------------------------------------
--
procedure run_process
(
errbuf		 out nocopy varchar2,
retcode		 out nocopy number,
p_business_group_id     in      number,
p_batch_operation	in	varchar2,
p_batch_id		in	number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.validate                                                  --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id it will validate the batch and insert its        --
 -- element entries into the necessary base tables.  Then depending on--
 -- the mode of operation passed in i.e. VALIDATE or TRANSFER the     --
 -- inserted element entries will either be ROLLED BACK or not.       --
 -----------------------------------------------------------------------
--
procedure validate
(
p_business_group_id 	in  	number,
p_batch_operation   	in  	varchar2,
p_batch_id		in	number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_status                                                --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch and control totals.                                  --
 -----------------------------------------------------------------------
--
procedure set_status
(
p_business_group_id  	in  	number,
p_batch_operation   	in  	varchar2,
p_batch_id		in	number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_line_status                                           --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch lines.                                               --
 -----------------------------------------------------------------------
--
procedure set_line_status
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number,
p_asg_id                in      number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.set_header_status                                         --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id and the mode of operation it will set the status --
 -- of the batch header and control totals.                           --
 -----------------------------------------------------------------------
--
procedure set_header_status
(
p_business_group_id     in      number,
p_batch_operation       in      varchar2,
p_batch_id              in      number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.purge                                                     --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a batch id it will delete all records associated with the   --
 -- batch from all the temporary batch tables.  Any messages          --
 -- associated with the batch will also be deleted from the           --
 -- PAY_MESSAGE_LINES table.                                          --
 -----------------------------------------------------------------------
--
procedure purge
(
p_batch_id	in	number
);
--
 -----------------------------------------------------------------------
 -- NAME                                                              --
 -- payplnk.validate_lines                                            --
 --                                                                   --
 -- DESCRIPTION                                                       --
 -- Given a asg id it will validate its batch lines and insert its    --
 -- element entries into the necessary base tables.  Then depending on--
 -- the mode of operation passed in i.e. VALIDATE or TRANSFER the     --
 -- inserted element entries will either be ROLLED BACK or not.       --
 -----------------------------------------------------------------------
--
procedure validate_lines
(
p_asg_id                in number,
p_asg_act_id            in number,
p_process_mode          in varchar,
p_batch_id              in number,
p_business_group_id     in number
);
--
--
-- A global value to inform the batch table triggers where the call was
-- originated from.
g_payplnk_call   boolean := false;
-- Global variables to indicate the retry duration and maximum wait for
-- any interlock during inserting element entries.
g_lock_interval  number := null;
g_lock_max_wait  number := null;
--
end payplnk;

/
