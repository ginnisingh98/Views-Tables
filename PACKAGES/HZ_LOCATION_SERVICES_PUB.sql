--------------------------------------------------------
--  DDL for Package HZ_LOCATION_SERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOCATION_SERVICES_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHLCSVS.pls 120.11 2006/08/17 10:19:22 idali noship $*/
/*#
 * This package contains the public APIs for submitting address validation requests.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Location Service
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Location Service APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

-- This procedure set proxy
PROCEDURE set_proxy (
  p_proxy_host    VARCHAR2 DEFAULT NULL,
  p_proxy_port    VARCHAR2 DEFAULT NULL,
  p_proxy_bypass  VARCHAR2 DEFAULT NULL);

PROCEDURE set_authentication (
  p_req                     IN OUT NOCOPY UTL_HTTP.REQ,
  p_adapter_id              IN NUMBER );

PROCEDURE address_validation (
  Errbuf                        OUT NOCOPY VARCHAR2,
  Retcode                       OUT NOCOPY VARCHAR2,
  p_validation_status_op         IN VARCHAR2,
  p_validation_status_code       IN VARCHAR2,
  p_date_validated_op            IN VARCHAR2,
  p_date_validated               IN VARCHAR2,
  p_last_update_date_op          IN VARCHAR2,
  p_last_update_date             IN VARCHAR2,
  p_country                      IN VARCHAR2,
  p_adapter_content_source       IN VARCHAR2,
  p_overwrite_threshold          IN VARCHAR2 );

PROCEDURE address_validation_worker (
  Errbuf                        OUT NOCOPY VARCHAR2,
  Retcode                       OUT NOCOPY VARCHAR2,
  p_adapter_id                   IN NUMBER,
  p_overwrite_threshold          IN VARCHAR2,
  p_country                      IN VARCHAR2,
  p_nvl_vsc                      IN VARCHAR2,
  p_from_vsc                     IN VARCHAR2,
  p_to_vsc                       IN VARCHAR2,
  p_from_lud                     IN VARCHAR2,
  p_to_lud                       IN VARCHAR2,
  p_nvl_dv                       IN VARCHAR2,
  p_from_dv                      IN VARCHAR2,
  p_to_dv                        IN VARCHAR2,
  p_num_batch                    IN NUMBER,
  p_batch_sequence               IN NUMBER );

PROCEDURE get_validated_xml (
  p_adapter_id              IN NUMBER,
  p_overwrite_threshold     IN VARCHAR2,
  p_location_id             IN NUMBER,
  p_country                 IN VARCHAR2,
  p_address1                IN VARCHAR2,
  p_address2                IN VARCHAR2,
  p_address3                IN VARCHAR2,
  p_address4                IN VARCHAR2,
  p_county                  IN VARCHAR2,
  p_city                    IN VARCHAR2,
  p_prov_state_admin_code   IN VARCHAR2,
  p_postal_code             IN VARCHAR2,
  p_validation_status_code  IN VARCHAR2 );

PROCEDURE submit_addrval_request (
  p_adapter_log_id          IN NUMBER,
  p_adapter_id              IN NUMBER DEFAULT NULL,
  p_country_code            IN VARCHAR2 DEFAULT NULL,
  p_module                  IN VARCHAR2 DEFAULT NULL,
  p_module_id               IN NUMBER   DEFAULT NULL,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2 );

/*#
 * Use this API to send an XML document to a vendor's adapter to validate and to receive the
 * validated address in XML format. This API requires an adapter_id or country_code to call
 * address validation against different vendor adapters.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Address Validation
 * @rep:doccd 120hztig.pdf Location Service APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE submit_addrval_doc (
  p_addrval_doc               IN OUT NOCOPY NCLOB,
  p_adapter_id                IN NUMBER DEFAULT NULL,
  p_country_code              IN VARCHAR2 DEFAULT NULL,
  p_module                    IN VARCHAR2 DEFAULT NULL,
  p_module_id                 IN NUMBER   DEFAULT NULL,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2 );

FUNCTION get_adapter_id(p_adapter_id IN NUMBER DEFAULT NULL,
                        p_country_code IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION outdoc_rule(p_subscription_guid   IN RAW,
                     p_event               IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;

FUNCTION indoc_rule(p_subscription_guid   IN RAW,
                     p_event               IN OUT NOCOPY wf_event_t ) RETURN VARCHAR2;

END HZ_LOCATION_SERVICES_PUB;
 

/
