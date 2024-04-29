--------------------------------------------------------
--  DDL for Package INV_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ORG" AUTHID CURRENT_USER AS
/* $Header: INVPEO1S.pls 120.0 2005/05/25 05:15:09 appldev noship $ */
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
 Name        : inv_org     (HEADER)

 Description : This package declares procedures required to validate
               organizations to be deleted from the database. It is used
               primarily by the Define Organization form (PERORDOR).

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    10-JUN-93 TMATHERS             Date created.
 	 05/27/96  gkokts 		Moved to admin/sql from invpeorg.pkh
					Also, commented out show errors.
*/
--
  PROCEDURE inv_predel_validation (p_organization_id   IN number);
--
END inv_org;

 

/
