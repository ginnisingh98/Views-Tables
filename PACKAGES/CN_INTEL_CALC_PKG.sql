--------------------------------------------------------
--  DDL for Package CN_INTEL_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_INTEL_CALC_PKG" AUTHID CURRENT_USER AS
/* $Header: cntcalcs.pls 120.1 2005/07/20 10:22:12 mblum noship $ */
--
-- Package Name
--   CN_INTEL_CALC_PKG
-- Purpose
--   Table handler for CN_SRP_INTEL_PERIODS
-- Form
--   N/A
-- Block
--   N/A
--
-- History
--   16-SEP-99  Yonghong Mao  Created

procedure insert_row (
		      x_srp_intel_period_id                IN NUMBER,
		      x_salesrep_id                        IN NUMBER,
		      x_org_id                             IN NUMBER,
		      x_period_id                          IN NUMBER,
		      x_processing_status_code             IN VARCHAR2,
		      x_process_all_flag                   IN VARCHAR2,
		      x_attribute_category                 IN VARCHAR2 := null,
		      x_attribute1                         IN VARCHAR2 := null,
		      x_attribute2                         IN VARCHAR2 := null,
		      x_attribute3                         IN VARCHAR2 := null,
		      x_attribute4                         IN VARCHAR2 := null,
		      x_attribute5                         IN VARCHAR2 := null,
		      x_attribute6                         IN VARCHAR2 := null,
		      x_attribute7                         IN VARCHAR2 := null,
		      x_attribute8                         IN VARCHAR2 := null,
		      x_attribute9                         IN VARCHAR2 := null,
		      x_attribute10                        IN VARCHAR2 := null,
		      x_attribute11                        IN VARCHAR2 := null,
		      x_attribute12                        IN VARCHAR2 := null,
		      x_attribute13                        IN VARCHAR2 := null,
		      x_attribute14                        IN VARCHAR2 := null,
                      x_attribute15                        IN VARCHAR2 := null,
                      x_creation_date                      IN DATE := sysdate,
                      x_created_by                         IN NUMBER := fnd_global.user_id,
                      x_last_update_date                   IN DATE := sysdate,
                      x_last_updated_by                    IN NUMBER := fnd_global.user_id,
                      x_last_update_login                  IN NUMBER := fnd_global.login_id,
                      x_start_date                         IN DATE := null,
                      x_end_date                           IN DATE := null);

PROCEDURE lock_row (
		    x_srp_intel_period_id             IN NUMBER,
		    x_salesrep_id                     IN NUMBER,
		    x_period_id                       IN NUMBER,
		    x_processing_status_code          IN VARCHAR2,
		    x_process_all_flag                IN VARCHAR2,
                    x_start_date                      IN DATE := null,
                    x_end_date                        IN DATE := NULL,
		    x_attribute_category              IN VARCHAR2 := null,
		    x_attribute1                      IN VARCHAR2 := null,
		    x_attribute2                      IN VARCHAR2 := null,
		    x_attribute3                      IN VARCHAR2 := null,
		    x_attribute4                      IN VARCHAR2 := null,
		    x_attribute5                      IN VARCHAR2 := null,
		    x_attribute6                      IN VARCHAR2 := null,
		    x_attribute7                      IN VARCHAR2 := null,
		    x_attribute8                      IN VARCHAR2 := null,
		    x_attribute9                      IN VARCHAR2 := null,
		    x_attribute10                     IN VARCHAR2 := null,
		    x_attribute11                     IN VARCHAR2 := null,
		    x_attribute12                     IN VARCHAR2 := null,
		    x_attribute13                     IN VARCHAR2 := null,
                    x_attribute14                     IN VARCHAR2 := null,
                    x_attribute15                     IN VARCHAR2 := null);
PROCEDURE update_row (
		    x_srp_intel_period_id             IN NUMBER,
		    x_salesrep_id                     IN NUMBER,
		    x_period_id                       IN NUMBER,
		    x_start_date                      IN DATE,
		    x_end_date                        IN DATE,
		    x_processing_status_code          IN VARCHAR2,
		    x_process_all_flag                IN VARCHAR2,
		    x_attribute_category              IN VARCHAR2,
		    x_attribute1                      IN VARCHAR2,
		    x_attribute2                      IN VARCHAR2,
		    x_attribute3                      IN VARCHAR2,
		    x_attribute4                      IN VARCHAR2,
		    x_attribute5                      IN VARCHAR2,
		    x_attribute6                      IN VARCHAR2,
		    x_attribute7                      IN VARCHAR2,
		    x_attribute8                      IN VARCHAR2,
		    x_attribute9                      IN VARCHAR2,
		    x_attribute10                     IN VARCHAR2,
		    x_attribute11                     IN VARCHAR2,
		    x_attribute12                     IN VARCHAR2,
		    x_attribute13                     IN VARCHAR2,
                    x_attribute14                     IN VARCHAR2,
                    x_attribute15                     IN VARCHAR2,
                    x_last_update_date                IN DATE,
                    x_last_updated_by                 IN NUMBER,
                    x_last_update_login               IN NUMBER);

PROCEDURE delete_row (
		      x_srp_intel_period_id           IN NUMBER
		      );

end CN_INTEL_CALC_PKG;
 

/
