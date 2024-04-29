--------------------------------------------------------
--  DDL for Package IGS_AD_EXTRACURR_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_EXTRACURR_ACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI85S.pls 115.11 2003/11/11 07:16:31 gmaheswa ship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_interest_id                OUT NOCOPY     NUMBER,
    x_person_id                         IN     NUMBER,
    x_interest_type_code                IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_level_of_interest                 IN     VARCHAR2,
    x_level_of_participation            IN     VARCHAR2,
    x_sport_indicator                   IN     VARCHAR2,
    x_sub_interest_type_code            IN     VARCHAR2,
    x_interest_name                     IN     VARCHAR2,
    x_team                              IN     VARCHAR2,
    x_wh_update_date                    IN     DATE,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_last_update_date                  OUT NOCOPY    DATE,
    x_msg_Data                          OUT NOCOPY    VARCHAR2,
    x_return_Status                     OUT NOCOPY    VARCHAR2,
    x_object_version_number             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_interest_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_interest_type_code                IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_hours_per_week                    IN     NUMBER,
    x_weeks_per_year                    IN     NUMBER,
    x_level_of_interest                 IN     VARCHAR2,
    x_level_of_participation            IN     VARCHAR2,
    x_sport_indicator                   IN     VARCHAR2,
    x_sub_interest_type_code            IN     VARCHAR2,
    x_interest_name                     IN     VARCHAR2,
    x_team                              IN     VARCHAR2,
    x_wh_update_date                    IN     DATE,
    x_activity_source_cd                IN     VARCHAR2 DEFAULT NULL,
    x_last_update_date                  IN OUT NOCOPY DATE,
    x_msg_Data                          OUT NOCOPY    VARCHAR2,
    x_return_Status                     OUT NOCOPY    VARCHAR2,
    x_object_version_number             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );
END Igs_Ad_Extracurr_Act_Pkg;

 

/
