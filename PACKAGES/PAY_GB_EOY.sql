--------------------------------------------------------
--  DDL for Package PAY_GB_EOY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EOY" AUTHID CURRENT_USER AS
/* $Header: payeoy.pkh 115.0 99/07/17 05:38:27 porting ship $ */
/* Copyright (c) Oracle Corporation 1995. All rights reserved

  Name          : PAYEOY
  Description   : End of year control process
  Author        : P.Driver
  Date Created  : 17/11/95

  Change List
  -----------
    Date        Name            Vers     Bug No   Description

    +-----------+---------------+--------+--------+-----------------------+
     30-JUL-96   J.ALLOUN                          Added error handling.
     12-JUN-97   A.PARKES        40.4              Changed IS to AS for R11
    */


PROCEDURE eoy;
END;

 

/
