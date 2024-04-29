--------------------------------------------------------
--  DDL for Package IGW_SPONSOR_ACTION_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SPONSOR_ACTION_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtspas.pls 115.2 2002/11/15 00:49:28 ashkumar noship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid              OUT NOCOPY VARCHAR2,
      p_proposal_id        IN NUMBER,
      p_comments           IN VARCHAR2,
      p_sponsor_action_code IN VARCHAR2,
      p_sponsor_action_date IN DATE,
      x_return_status      OUT NOCOPY VARCHAR2,
      p_mode               IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_comment_id            IN NUMBER,
      p_comments              IN VARCHAR2,
      p_sponsor_action_code IN VARCHAR2,
      p_sponsor_action_date IN DATE,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      p_mode                  IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Row
   (
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END IGW_SPONSOR_ACTION_TBH;

 

/
