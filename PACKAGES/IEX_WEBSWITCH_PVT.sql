--------------------------------------------------------
--  DDL for Package IEX_WEBSWITCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_WEBSWITCH_PVT" AUTHID CURRENT_USER as
/* $Header: iexvadss.pls 120.2 2005/07/08 13:54:08 jypark noship $ */

  TYPE cgi_switch_rec_type IS RECORD
                (
                  cgi_switch_id          NUMBER,
                  object_version_number  NUMBER,
                  program_id             NUMBER,
                  enabled_flag           VARCHAR2(1),
                  switch_code            VARCHAR2(240),
                  switch_type            VARCHAR2(240),
                  is_required_yn         VARCHAR2(10),
                  sort_order             NUMBER,
                  data_separator         VARCHAR2(240),
                  query_string_id        NUMBER,
                  last_update_date       DATE,
                  last_updated_by        NUMBER,
                  creation_date          DATE,
                  created_by             NUMBER,
                  last_update_login      NUMBER,
                  org_id                 NUMBER,
                  attribute_category     VARCHAR2(30),
                  attribute1             VARCHAR2(150),
                  attribute2             VARCHAR2(150),
                  attribute3             VARCHAR2(150),
                  attribute4             VARCHAR2(150),
                  attribute5             VARCHAR2(150),
                  attribute6             VARCHAR2(150),
                  attribute7             VARCHAR2(150),
                  attribute8             VARCHAR2(150),
                  attribute9             VARCHAR2(150),
                  attribute10            VARCHAR2(150),
                  attribute11            VARCHAR2(150),
                  attribute12            VARCHAR2(150),
                  attribute13            VARCHAR2(150),
                  attribute14            VARCHAR2(150),
                  attribute15            VARCHAR2(150)
                );

  TYPE switch_data_rec_type IS RECORD
                (
                  switch_data_id         NUMBER,
                  program_id             NUMBER,
                  object_version_number  NUMBER,
                  first_name_yn          VARCHAR2(10),
                  last_name_yn           VARCHAR2(10),
                  address_yn             VARCHAR2(10),
                  city_yn                VARCHAR2(10),
                  state_yn               VARCHAR2(10),
                  zip_yn                 VARCHAR2(10),
                  country_yn             VARCHAR2(10),
                  sort_order             NUMBER,
                  enabled_flag           VARCHAR2(1),
                  cgi_switch_id          NUMBER,
                  last_update_date       DATE,
                  last_updated_by        NUMBER,
                  creation_date          DATE,
                  created_by             NUMBER,
                  last_update_login      NUMBER,
                  org_id                 NUMBER,
                  attribute_category     VARCHAR2(30),
                  attribute1             VARCHAR2(150),
                  attribute2             VARCHAR2(150),
                  attribute3             VARCHAR2(150),
                  attribute4             VARCHAR2(150),
                  attribute5             VARCHAR2(150),
                  attribute6             VARCHAR2(150),
                  attribute7             VARCHAR2(150),
                  attribute8             VARCHAR2(150),
                  attribute9             VARCHAR2(150),
                  attribute10            VARCHAR2(150),
                  attribute11            VARCHAR2(150),
                  attribute12            VARCHAR2(150),
                  attribute13            VARCHAR2(150),
                  attribute14            VARCHAR2(150),
                  attribute15            VARCHAR2(150)
                );
  PROCEDURE Create_WebSwitch(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      );
  PROCEDURE Update_WebSwitch(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      );

END;

 

/
