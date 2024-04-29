--------------------------------------------------------
--  DDL for Package IGW_PROP_SPECIAL_REVIEWS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_SPECIAL_REVIEWS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtrevs.pls 115.2 2002/11/15 00:46:08 ashkumar ship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_special_review_code    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_approval_type_code     IN VARCHAR2,
      p_protocol_number        IN VARCHAR2,
      p_application_date       IN DATE,
      p_approval_date          IN DATE,
      p_comments               IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_special_review_code    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_approval_type_code     IN VARCHAR2,
      p_protocol_number        IN VARCHAR2,
      p_application_date       IN DATE,
      p_approval_date          IN DATE,
      p_comments               IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      p_mode                   IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Special_Reviews_Tbh;

 

/
