--------------------------------------------------------
--  DDL for Package ALR_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ALR_PROFILE" AUTHID CURRENT_USER as
/* $Header: ALPROFLS.pls 115.1 99/07/16 19:01:26 porting ship $ */

    /*
    ** PUT - sets a profile option to a value
    */
    procedure PUT(NAME in varchar2, VAL in varchar2);

    /*
    ** GET - gets the value of a profile option
    */
    procedure GET(NAME in varchar2, VAL out varchar2);

    /*
    ** VALUE - returns the value of a profile option
    */
    function  VALUE(NAME in varchar2) return varchar2;

end ALR_PROFILE;

 

/
