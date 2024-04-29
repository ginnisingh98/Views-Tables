--------------------------------------------------------
--  DDL for Package ENG_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ORG" AUTHID CURRENT_USER AS
/* $Header: ENGORGDS.pls 115.1 99/07/27 08:40:41 porting ship $ */
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
 Name        : eng_org     (BODY)

 Description : This package declares procedures required to validate
               organizations   to be deleted from the database. It is used
               primarily by the Define Organization form (PERORDOR).
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    02-DEC-93 JThuringer           Date Created.
*/
--
  PROCEDURE eng_predel_validation (p_organization_id   IN number);
--
END eng_org;

 

/
