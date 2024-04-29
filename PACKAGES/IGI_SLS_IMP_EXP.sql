--------------------------------------------------------
--  DDL for Package IGI_SLS_IMP_EXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_IMP_EXP" AUTHID CURRENT_USER AS
-- $Header: igislses.pls 120.2.12010000.2 2008/08/04 13:07:37 sasukuma ship $

   PROCEDURE insert_sls_data(sls_tab IN VARCHAR2,schema_name IN VARCHAR2,core_tab in varchar2);

   PROCEDURE create_sls_datafix  (errbuf out nocopy varchar2,retcode out nocopy number,request_type in VARCHAR2);

END IGI_SLS_IMP_EXP;

/
