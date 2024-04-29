--------------------------------------------------------
--  DDL for Package AD_TRACKABLE_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_TRACKABLE_ENTITIES_PKG" AUTHID CURRENT_USER AS
-- $Header: adcodlins.pls 120.2 2006/03/10 08:07:59 rahkumar noship $

  -- Procedure declarations follows

  PROCEDURE validate_name(p_te IN VARCHAR2);
  PROCEDURE validate_level(p_level IN VARCHAR2);
  PROCEDURE create_te ( p_trackable_entity_name IN  VARCHAR2 ,
                        p_desc IN VARCHAR2,
                        p_type IN  VARCHAR2,
                        x_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

  PROCEDURE get_code_level (
              p_trackable_entity_name IN  VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

  PROCEDURE set_code_level (
              p_trackable_entity_name IN  VARCHAR2,
              p_te_level            IN  VARCHAR2,
              p_baseline              IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

  PROCEDURE get_used_status (
              p_trackable_entity_name IN  VARCHAR2,
              x_used_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


  PROCEDURE set_used_status (
              p_trackable_entity_name IN  VARCHAR2,
              p_used_status           IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

  PROCEDURE get_load_status (
              p_trackable_entity_name IN  VARCHAR2,
              x_load_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

  PROCEDURE set_load_status (
              p_trackable_entity_name IN  VARCHAR2,
              p_load_status           IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


  PROCEDURE get_te_info (
              p_trackable_entity_name IN  VARCHAR2,
              x_desc                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_type                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_used_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_load_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

  PROCEDURE set_te_info (
              p_trackable_entity_name IN  VARCHAR2,
              p_trackable_entity_desc IN VARCHAR2,
              p_type                  IN VARCHAR2,
              p_te_level              IN VARCHAR2,
              p_baseline              IN VARCHAR2,
              p_used_status           IN VARCHAR2,
              p_load_status           IN VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
-----------

END AD_TRACKABLE_ENTITIES_PKG;

 

/
