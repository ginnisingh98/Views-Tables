--------------------------------------------------------
--  DDL for Package PAY_CA_AMT_IN_WORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_AMT_IN_WORDS" AUTHID CURRENT_USER as
/* $Header: pycaamtw.pkh 115.3 2003/06/03 08:14:26 sfmorris noship $*/
/*

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
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

    Name        : pay_ca_amt_in_words

    Description : Package for converting amount in words.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   04-Jan-2002  vpandya     115.0           Created
   03-Jun-2003  sfmorris    115.3  2888822  Added parameters p_denomination and
                                            p_sub_denomination to support
                                            output in Euros for French
                                            Localisation
--
*/

  FUNCTION pay_amount_in_words(in_numeral IN NUMBER,
                               p_language IN VARCHAR2,
                               p_denomination IN VARCHAR2 default 'DOLLARS',
                               p_sub_denomination IN VARCHAR2 default 'CENTS') RETURN VARCHAR2;
end pay_ca_amt_in_words;

 

/
