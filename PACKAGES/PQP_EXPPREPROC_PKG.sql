--------------------------------------------------------
--  DDL for Package PQP_EXPPREPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXPPREPROC_PKG" AUTHID CURRENT_USER as
/* $Header: pqexrppr.pkh 120.1 2006/03/03 15:56:55 sshetty noship $ */
/*

--
*/
PROCEDURE range_cursor ( pactid in  number  ,
                         sqlstr out nocopy varchar2
                       );
PROCEDURE action_creation ( pactid in number   ,
                            stperson in number ,
                            endperson in number,
                            chunk in number
                          );
PROCEDURE sort_action ( payactid   in     varchar2 ,
                        sqlstr     in out nocopy varchar2 ,
                        len        out nocopy    number
                      );


procedure deinitialize (pactid in number);

FUNCTION get_parameter(name in varchar2       ,
                       parameter_list varchar2) return varchar2;
PRAGMA RESTRICT_REFERENCES(get_parameter, WNDS, WNPS);
--
END ;

 

/
