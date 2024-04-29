--------------------------------------------------------
--  DDL for Package IGS_EN_SPI_RCOND_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPI_RCOND_LGCY_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSENB5S.pls 120.0 2006/04/10 04:23:00 bdeviset noship $ */

  /*---------------------------------------------------------------------------------------
   Created by  : Basanth Devisetty, Oracle Student Systems Oracle IDC
   Puprose: This is the spec for importing legacy intermission return conditions.
            Created for Intermission Authorization to Return Build Bug# 5083465
  --Change History:
  --Who         When            What

---------------------------------------------------------------------------------------------*/

  TYPE en_spi_rcond_rec_type IS RECORD
         (
          person_number IGS_EN_SPI_RCOND_INTS.person_number%TYPE,
          program_cd IGS_EN_SPI_RCOND_INTS.program_cd%TYPE,
          start_dt IGS_EN_SPI_RCOND_INTS.start_dt%TYPE,
          return_condition IGS_EN_SPI_RCOND_INTS.return_condition%TYPE,
          status_code IGS_EN_SPI_RCOND_INTS.status_code%TYPE,
          approved_dt IGS_EN_SPI_RCOND_INTS.approved_dt%TYPE,
          approver_number IGS_EN_SPI_RCOND_INTS.approver_number%TYPE
         );

  PROCEDURE create_student_intm_rcond
                    ( p_api_version       IN  NUMBER,
                      p_init_msg_list     IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
                      p_commit            IN  VARCHAR2 DEFAULT  FND_API.G_FALSE,
                      p_validation_level  IN  NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
                      p_intm_rcond_rec    IN  en_spi_rcond_rec_type,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_count         OUT NOCOPY NUMBER,
                      x_msg_data          OUT NOCOPY VARCHAR2);

END igs_en_spi_rcond_lgcy_pub;

 

/
