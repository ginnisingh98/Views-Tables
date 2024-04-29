--------------------------------------------------------
--  DDL for Package IGS_OR_GEN_012_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_GEN_012_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOR12S.pls 120.3 2006/02/06 23:39:41 pkpatel ship $ */



  PROCEDURE create_organization (
      p_institution_cd                    IN  VARCHAR2,
      p_name                              IN  VARCHAR2,
      p_status                            IN  VARCHAR2,
      p_attribute_category                IN  VARCHAR2,
      p_attribute1                        IN  VARCHAR2,
      p_attribute2                        IN  VARCHAR2,
      p_attribute3                        IN  VARCHAR2,
      p_attribute4                        IN  VARCHAR2,
      p_attribute5                        IN  VARCHAR2,
      p_attribute6                        IN  VARCHAR2,
      p_attribute7                        IN  VARCHAR2,
      p_attribute8                        IN  VARCHAR2,
      p_attribute9                        IN  VARCHAR2,
      p_attribute10                       IN  VARCHAR2,
      p_attribute11                       IN  VARCHAR2,
      p_attribute12                       IN  VARCHAR2,
      p_attribute13                       IN  VARCHAR2,
      p_attribute14                       IN  VARCHAR2,
      p_attribute15                       IN  VARCHAR2,
      p_attribute16                       IN  VARCHAR2,
      p_attribute17                       IN  VARCHAR2,
      p_attribute18                       IN  VARCHAR2,
      p_attribute19                       IN  VARCHAR2,
      p_attribute20                       IN  VARCHAR2,
      p_return_status                     OUT NOCOPY VARCHAR2,
      p_msg_data                          OUT NOCOPY VARCHAR2,
      p_party_id                          OUT NOCOPY NUMBER,
      p_object_version_number             IN OUT NOCOPY NUMBER,
      p_attribute21                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute22                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute23                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute24                       IN  VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_organization (
      p_party_id                          IN  NUMBER,
      p_institution_cd                    IN  VARCHAR2,
      p_name                              IN  VARCHAR2,
      p_status                            IN  VARCHAR2,
      p_last_update                       IN OUT NOCOPY  DATE,
      p_attribute_category                IN  VARCHAR2,
      p_attribute1                        IN  VARCHAR2,
      p_attribute2                        IN  VARCHAR2,
      p_attribute3                        IN  VARCHAR2,
      p_attribute4                        IN  VARCHAR2,
      p_attribute5                        IN  VARCHAR2,
      p_attribute6                        IN  VARCHAR2,
      p_attribute7                        IN  VARCHAR2,
      p_attribute8                        IN  VARCHAR2,
      p_attribute9                        IN  VARCHAR2,
      p_attribute10                       IN  VARCHAR2,
      p_attribute11                       IN  VARCHAR2,
      p_attribute12                       IN  VARCHAR2,
      p_attribute13                       IN  VARCHAR2,
      p_attribute14                       IN  VARCHAR2,
      p_attribute15                       IN  VARCHAR2,
      p_attribute16                       IN  VARCHAR2,
      p_attribute17                       IN  VARCHAR2,
      p_attribute18                       IN  VARCHAR2,
      p_attribute19                       IN  VARCHAR2,
      p_attribute20                       IN  VARCHAR2,
      p_return_status                     OUT NOCOPY VARCHAR2,
      p_msg_data                          OUT NOCOPY VARCHAR2,
      p_object_version_number             IN OUT NOCOPY NUMBER,
      p_attribute21                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute22                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute23                       IN  VARCHAR2 DEFAULT NULL,
      p_attribute24                       IN  VARCHAR2 DEFAULT NULL
  );

PROCEDURE get_where_clause(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
 );

PROCEDURE get_where_clause_form(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
 );

PROCEDURE get_where_clause_api(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
 );

PROCEDURE get_where_clause_form1(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
 );

PROCEDURE get_where_clause_api1(
      p_function_name                     IN fnd_lookup_values.lookup_code%TYPE,
      p_where_clause                      OUT NOCOPY VARCHAR2
 );

END igs_or_gen_012_pkg;

 

/
