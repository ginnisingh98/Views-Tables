--------------------------------------------------------
--  DDL for Package Body INV_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ORG" AS
/* $Header: INVPEO1B.pls 120.0 2005/05/27 09:56:28 appldev noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1993 Oracle Corporation UK Ltd.,                *
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
 ****************************************************************** */
/*
 Name        : inv_org     (BODY)

 Description : This package declares procedures required to validate
               organizations   to be deleted from the database. It is used
               primarily by the Define Organization form (PERORDOR).
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    10-JUN-93 TMathers             Date Created.
         05/27/96  gkokts               Moved to admin/sql from invpeorg.pkh
                                        Also, commented out show errors.
*/
--
  PROCEDURE inv_predel_validation (p_organization_id   IN number) is
--
-- Parameters
-- p_organization_id : UID of organization being deleted.
--
-- Local Variable
v_dummy varchar2(1);
--
begin
 hr_utility.set_location('inv_org.inv_predel_validation',1);
 select 1
 into v_dummy
 from sys.dual
 where exists(select 'exists'
              from  mtl_parameters mp
              where mp.organization_id = p_organization_id);
--
-- If got through then error
--
-- Note don't forget to change both  the application_id and
-- the message name of this message.
 hr_utility.set_message(801,'HR_6890_INV_MTL_P_EXISTS');
 hr_utility.raise_error;
--
exception
  when no_data_found then null;
end inv_predel_validation;
--
END inv_org;

/
