--------------------------------------------------------
--  DDL for Package PAY_DB_LOCALISATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DB_LOCALISATION_PKG" AUTHID CURRENT_USER as
/* $Header: pylocaln.pkh 115.0 99/07/17 06:15:57 porting ship $ */
--
 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_db_localisation_pkg

    Description :

    Uses        : n/a
    Used By     : n/a

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    26-Nov-92   J.S.Hobbs     3.0                First Created.
    26-Nov-92   C.Swan        3.0                Removed declaration of
                                                 create_name_translations().
    16-Feb-93   J.S.Hobbs     3.2                Added create_BF_localisation
    01-Apr-93   J.S.Hobbs     3.3                Tidied up package.
    05-OCT-94   R.Fine        40.3               Renamed package to
                                                 pay_db_localisation_pkg

                                                                            */
--
 -------------------------------- create_GB_localisation ----------------------
 /*
 NAME
 DESCRIPTION
 NOTES
 */
--
PROCEDURE create_GB_localisation;
--
 -------------------------------- create_BF_localisation ----------------------
 /*
 NAME
 DESCRIPTION
 NOTES
 */
--
PROCEDURE create_BF_localisation;
--
end pay_db_localisation_pkg;

 

/
