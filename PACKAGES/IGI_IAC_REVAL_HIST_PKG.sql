--------------------------------------------------------
--  DDL for Package IGI_IAC_REVAL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REVAL_HIST_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiarhs.pls 120.2.12000000.1 2007/08/01 16:17:11 npandya noship $


 Function Insert_rows
     ( P_Asset_id Number,
       P_Book_type_code Varchar2) return boolean;

    Function Delete_rows
     ( P_Asset_id Number,
       P_Book_type_code Varchar2) return boolean;

   END; -- Package spec

 

/
