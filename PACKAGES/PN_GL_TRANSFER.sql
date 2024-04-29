--------------------------------------------------------
--  DDL for Package PN_GL_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_GL_TRANSFER" AUTHID CURRENT_USER as
-- $Header: PNGLTRNS.pls 115.1 2002/10/18 10:28:24 ahhkumar noship $

Procedure gl_transfer (p_journal_category        varchar2 ,
                       P_selection_type          varchar2 ,
                       P_batch_name              varchar2,
                       p_from_date               date,
                       p_to_date                 date,
                       P_validate_account        varchar2 ,
                       p_gl_transfer_mode        varchar2 ,
                       p_submit_journal_import   varchar2 ,
                       p_process_days            varchar2,
                       p_debug_flag              varchar2
                       ) ;
END PN_GL_TRANSFER;

 

/
