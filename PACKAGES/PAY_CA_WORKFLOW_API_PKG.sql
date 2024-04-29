--------------------------------------------------------
--  DDL for Package PAY_CA_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_WORKFLOW_API_PKG" AUTHID CURRENT_USER AS
/* $Header: paycawfapipkg.pkh 120.0 2005/05/29 11:10 appldev noship $ */
--
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

    Package Name : PAY_CA_WORKFLOW_API_PKG
    Package File Name : paycawfapipkg.pkh
    Description       : This package is used by the Canadian Payroll Process Workflow


   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   24-JUN-2004  ssouresr    115.0            Created

*/

procedure get_roe_assignment_info(document_id   in varchar2,
                                  display_type  in varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2);

procedure get_roe_mag_assignment_info(document_id   in varchar2,
                                      display_type  in varchar2,
                                      document      in out nocopy varchar2,
                                      document_type in out nocopy varchar2);
end pay_ca_workflow_api_pkg;

 

/
