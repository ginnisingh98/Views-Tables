--------------------------------------------------------
--  DDL for Package IGS_PR_UPLOAD_EXT_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_UPLOAD_EXT_RESULTS" AUTHID CURRENT_USER AS
 /* $Header: IGSPR38S.pls 115.2 2002/12/22 20:47:14 dlarsen noship $ */

/****************************************************************************************************************
  ||  Created By : nmankodi
  ||  Created On : 07-NOV-2002
  ||  Purpose : This Job validates and uploads and then purges the Interface data for External Stats and Degree
Completion
  ||  This process can be called from the concurrent manager .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  dlarsen         12/10/2002      Added Procedure upload_external_completion for
  ||                                  SPA and SUSA Completion
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
PROCEDURE  upload_external_stats (
     errbuf                OUT NOCOPY     VARCHAR2,  -- Standard Error Buffer Variable
     retcode               OUT NOCOPY     NUMBER,    -- Standard Concurrent Return code
     p_batch_id            IN     NUMBER    -- The batch id which needs to be uploaded
);


PROCEDURE  upload_external_completion (
     errbuf                OUT NOCOPY     VARCHAR2,
     retcode               OUT NOCOPY     NUMBER,
     p_batch_id            IN             NUMBER,
     p_unit_set_method     IN             VARCHAR2
);

END IGS_PR_UPLOAD_EXT_RESULTS;


 

/
