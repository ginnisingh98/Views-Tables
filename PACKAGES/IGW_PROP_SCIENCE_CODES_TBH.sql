--------------------------------------------------------
--  DDL for Package IGW_PROP_SCIENCE_CODES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_SCIENCE_CODES_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtkeys.pls 115.3 2002/11/15 00:45:34 ashkumar ship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid          OUT NOCOPY VARCHAR2,
      p_proposal_id    IN NUMBER,
      p_science_code   IN VARCHAR2,
      x_return_status  OUT NOCOPY VARCHAR2,
      p_mode           IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_science_code          IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      p_mode                  IN  VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Science_Codes_Tbh;

 

/
