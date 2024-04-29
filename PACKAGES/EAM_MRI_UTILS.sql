--------------------------------------------------------
--  DDL for Package EAM_MRI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MRI_UTILS" AUTHID CURRENT_USER AS
/* $Header: EAMMRIUS.pls 115.2 2002/02/20 19:53:13 pkm ship   $ */

--
-- Valid error types.
--
  MSG_ERROR CONSTANT NUMBER := 1;
  MSG_WARNING CONSTANT NUMBER := 2;
  MSG_LOG CONSTANT NUMBER := 3;
  MSG_COLUMN CONSTANT NUMBER := 4;
  MSG_CONC CONSTANT NUMBER := 5;


  /**
   * This is almost a copy of WIP_JDI_Utils.Error_If_Batch. Just modified
   * the table name and such to make it usable for meter reading interface.
   */
  procedure error_if_batch(p_group_id  number,
                           p_new_process_status number,
                           p_where_clause varchar2,
                           p_error_type   number,
                           p_error_msg    varchar2);

  procedure error_if(p_current_rowid  in rowid,
                     p_interface_id in number,
                     p_condition in varchar2,
                     p_product_short_name in varchar2,
                     p_message_name in varchar2);


END eam_mri_utils;

 

/
