--------------------------------------------------------
--  DDL for Package PAY_PAYVIBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYVIBAL_PKG" AUTHID CURRENT_USER AS
/* $Header: pyvibal.pkh 115.0 99/07/17 06:48:46 porting ship $ */
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
 Name        : pay_payvibal_pkg (HEADER)
 File        : payvibal.pkh
 Description : This package declares functions and procedures which are used
               to return values for the forms4 form PAYVIBAL.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 40.0    11-NOV-93 AKelly               Date Created
 40.2    05-OCT-93 RFine                prepended 'PAY_' to package name
 =================================================================
*/
--
--
procedure get_dimension_contexts(p_route_id in number, p_context1 out varchar2,
                                                    p_context2 out varchar2,
                                                    p_context3 out varchar2);
--
--
end pay_payvibal_pkg;

 

/
