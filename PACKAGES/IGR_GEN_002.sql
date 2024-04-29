--------------------------------------------------------
--  DDL for Package IGR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSRT07S.pls 120.0 2005/06/01 21:27:06 appldev noship $ */
 /****************************************************************************
  Created By : nsinha
  Date Created On : 27-Aug-2003
  Purpose : 2885789 - Admin_Quick_Entry_RC

  Change History
  Who             When            What
  jchin		14-Feb-05	Modified package for IGR pseudo product

  (reverse chronological order - newest change first)
  *****************************************************************************/
  PROCEDURE Get_latest_batch_id (
      p_batch_id OUT NOCOPY NUMBER );

  PROCEDURE Get_batch_id (
      p_batch_id OUT NOCOPY NUMBER );

  PROCEDURE Delete_Inquiry_Dtls (
      p_interface_id IN NUMBER );

END igr_gen_002;

 

/
