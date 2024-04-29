--------------------------------------------------------
--  DDL for Package IGS_FI_GL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GL_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: IGSFI76S.pls 115.2 2002/11/29 00:31:03 nsidana noship $ */
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This package transfers the Student Finance transactions to GL
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

PROCEDURE transfer(errbuf                OUT NOCOPY VARCHAR2,
                   retcode               OUT NOCOPY NUMBER,
                   p_d_gl_date_start     VARCHAR2,
                   p_d_gl_date_end       VARCHAR2,
                   p_v_post_detail       VARCHAR2,
                   p_d_gl_date_posted    VARCHAR2,
                   p_v_jrnl_import       VARCHAR2);


FUNCTION get_party_number(p_n_party_id   hz_parties.party_id%TYPE) RETURN VARCHAR2;
END igs_fi_gl_interface;

 

/
