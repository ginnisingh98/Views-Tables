--------------------------------------------------------
--  DDL for Package AR_DEFERRAL_REASONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DEFERRAL_REASONS_GRP" AUTHID CURRENT_USER AS
/* $Header: ARXRDRS.pls 120.0.12000000.2 2009/01/15 20:02:58 mraymond ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

  TYPE line_flex_rec IS RECORD (
    interface_line_context     VARCHAR2(30)  DEFAULT NULL,
    interface_line_attribute1  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute2  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute3  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute4  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute5  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute6  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute7  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute8  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute9  VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute10 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute11 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute12 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute13 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute14 VARCHAR2(150) DEFAULT NULL,
    interface_line_attribute15 VARCHAR2(150) DEFAULT NULL,
    acceptance_date  DATE DEFAULT NULL
  );

PROCEDURE default_reasons (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_mode           IN  VARCHAR2 DEFAULT 'ALL',
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2);

PROCEDURE record_acceptance (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_order_line     IN  line_flex_rec,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2);

PROCEDURE record_proof_of_delivery (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_delivery_id    IN  NUMBER,
  p_pod_date       IN  DATE,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2);


END ar_deferral_reasons_grp;

 

/
