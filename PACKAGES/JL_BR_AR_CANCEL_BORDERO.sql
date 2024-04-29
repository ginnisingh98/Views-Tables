--------------------------------------------------------
--  DDL for Package JL_BR_AR_CANCEL_BORDERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_CANCEL_BORDERO" AUTHID CURRENT_USER AS
/*$Header: jlbrrcas.pls 120.3 2002/11/21 02:00:08 vsidhart ship $*/

PROCEDURE cancel_bordero (
        param_select_control            IN      number,
        param_bordero_id                IN      number,
        param_bordero_status            IN      varchar2,
        param_select_account_id         IN      number,
        param_option                    IN      varchar2,
        param_date                      IN      date,
        param_exit                      OUT NOCOPY     number);

END JL_BR_AR_CANCEL_BORDERO;

 

/
