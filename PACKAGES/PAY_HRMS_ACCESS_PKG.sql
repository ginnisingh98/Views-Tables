--------------------------------------------------------
--  DDL for Package PAY_HRMS_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HRMS_ACCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyhraces.pkh 115.0 2004/06/17 02:44 nmanchan noship $ */

  PROCEDURE Disable_Enable_HRMS (
            ERRBUF     out nocopy      VARCHAR2
           ,RETCODE    out nocopy      VARCHAR2
           );

END PAY_HRMS_ACCESS_PKG;


 

/
