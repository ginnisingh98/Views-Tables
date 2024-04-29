--------------------------------------------------------
--  DDL for Package Body IGI_DOS_DYNAMIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DOS_DYNAMIC" as
-- $Header: igidosbb.pls 115.11 2003/05/13 12:08:53 klakshmi ship $
    FUNCTION CREATE_SOURCE_ACCOUNTS_VIEW  (p_coa_id         IN   number
                                          ) return  varchar2
    is
    begin
       RETURN NULL;
    end     CREATE_SOURCE_ACCOUNTS_VIEW;


    FUNCTION CREATE_DEST_ACCOUNTS_VIEW  (p_coa_id         IN   number
                                          ) return  varchar2
    is
    BEGIN
       RETURN NULL;
    end CREATE_DEST_ACCOUNTS_VIEW;
END IGI_DOS_DYNAMIC;

/
