--------------------------------------------------------
--  DDL for Package M4U_PARTY_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_PARTY_QUERY" AUTHID CURRENT_USER AS
/*$Header: M4UQRPTS.pls 120.1 2005/06/14 12:03:35 appldev  $*/

        -- Name
        --      parse_param_list
        -- Purpose
        --      This procedure is called from the map m4u_230_party_qry_out.xgm
        --      The purpose of this procedure is to parse the parameter list
        --      supplied as input to each individual parameter.
        --      This is used becuase multiple optional parameters to the XGM are passed
        --      as a single Delimitor Separated Value list, since the ECXSTD/GETTPXML
        --      activity used in the workflow does allows us to specify only 5 paramters
        --      to the XGM
        -- Arguments
        --      p_param_list    - List of delimitor separated value
        --      x_org_gln       - Organization_GLN param filter to be used in Query Command
        --      x_duns_code     - Duns code parameter filter
        --      x_post_code     - Postal code parameter filter
        --      x_city          - City parameter filter
        --      x_return_status - return status 'S' on success else 'F'
        --      x_msg_data      - Failure message to be sent back to sysadmin
        -- Notes
        --      None.
        PROCEDURE parse_param_list(
                                        p_param_list            IN VARCHAR2,
                                        x_org_gln               OUT NOCOPY VARCHAR2,
                                        x_duns_code             OUT NOCOPY VARCHAR2,
                                        x_org_name              OUT NOCOPY VARCHAR2,
                                        x_post_code             OUT NOCOPY VARCHAR2,
                                        x_city                  OUT NOCOPY VARCHAR2,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_msg_data              OUT NOCOPY VARCHAR2

                                    );


        -- Name
        --      raise_partyqry_event
        -- Purpose
        --      This procedure is called from a concurrent program.
        --      The 'oracle.apps.m4u.partyqry.generate' is raised with the supplied event parameters
        --      The sequence m4u_wlqid_sequence is used to obtain unique event key.
        -- Arguments
        -- Notes
        --
        PROCEDURE raise_partyqry_event(
                x_errbuf                OUT NOCOPY VARCHAR2,
                x_retcode               OUT NOCOPY NUMBER,
                p_tp_gln                IN VARCHAR2,
                p_org_gln               IN VARCHAR2,
                p_org_name              IN VARCHAR2,
                p_duns                  IN VARCHAR2,
                p_postal_code           IN VARCHAR2,
                p_city                  IN VARCHAR2,
                p_org_status            IN VARCHAR2,
                p_msg_count             IN NUMBER
          );

        -- Name
        --      process_resp_org_data
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry
        --      This procedure recieves the organization info parsed from
        --      the UCCnet party-query command response
        -- Arguments
        --      p_org_gln                       - Party info received in response
        --      p_org_name                      - Party info received in response
        --      p_short_name                    - Party info received in response
        --      p_org_type                      - Party info received in response
        --      p_contact                       - Party info received in response
        --      p_org_status                    - Party info received in response
        --      p_role                          - Party info received in response
        --      p_addr1                         - Party info received in response
        --      p_addr2                         - Party info received in response
        --      p_city                          - Party info received in response
        --      p_state                         - Party info received in response
        --      p_zip                           - Party info received in response
        --      p_country                       - Party info received in response
        --      p_phone                         - Party info received in response
        --      p_fax                           - Party info received in response
        --      p_email                         - Party info received in response
        --      p_party_query_id                - Id of party command
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      None.
        PROCEDURE process_resp_org_data(
                p_org_gln                       IN      VARCHAR2,
                p_org_name                      IN      VARCHAR2,
                p_short_name                    IN      VARCHAR2,
                p_org_type                      IN      VARCHAR2,
                p_contact                       IN      VARCHAR2,
                p_org_status                    IN      VARCHAR2,
                p_role                          IN      VARCHAR2,
                p_addr1                         IN      VARCHAR2,
                p_addr2                         IN      VARCHAR2,
                p_city                          IN      VARCHAR2,
                p_state                         IN      VARCHAR2,
                p_zip                           IN      VARCHAR2,
                p_country_code                  IN      VARCHAR2,
                p_phone                         IN      VARCHAR2,
                p_fax                           IN      VARCHAR2,
                p_email                         IN      VARCHAR2,
                p_party_links                   IN      VARCHAR2,
                p_party_query_id                IN      VARCHAR2,
                p_ucc_doc_unique_id             IN      VARCHAR2,
                p_xmlg_internal_control_no      IN      NUMBER,
                p_collab_dtl_id                 IN      VARCHAR2,
                x_return_status                 OUT     NOCOPY  VARCHAR2,
                x_msg_data                      OUT     NOCOPY  VARCHAR2 );



        -- Name
        --      process_party_links
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry_in
        --      This procedure recieves the organization-links info parsed from
        --      the UCCnet party-query command response
        -- Arguments
        --      p_org_gln                       - Party info received in response
        --      p_linked_gln                    - GLN of Org linked to p_org_gln
        --      p_party_query_id                - Id of party command
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      This is only a Dummy API, can be extended based on future requirements
        PROCEDURE process_party_links(
                p_org_gln                       IN      VARCHAR2,
                p_linked_gln                    IN      VARCHAR2,
                p_party_query_id                IN      VARCHAR2,
                p_collab_id                     IN      VARCHAR2,
                p_ucc_doc_unique_id             IN      VARCHAR2,
                p_xmlg_internal_control_no      IN      NUMBER,
                x_collab_detail_id              OUT     NOCOPY  VARCHAR2,
                x_return_status                 OUT     NOCOPY  VARCHAR2,
                x_msg_data                      OUT     NOCOPY  VARCHAR2 );


        -- Name
        --      process_resp_doc
        -- Purpose
        --      This procedure is called from the XGM m4u_230_resp_partyqry_in
        --      This procedure updateds the UCCnet Party Query collaboration
        --      with details of the response document, and failre messages in case of error.
        -- Arguments
        --      p_party_query_id                - Id of party query command
        --      p_query_success_flag            - Flag - if query command was sucess/failure
        --      p_ucc_doc_unique_id             - UCCnet generated unique doc-id
        --      p_xmlg_internal_control_no      - retrieved from map, for logging
        --      x_collab_detail_id              - returned from update collab call
        --      x_return_status                 - flag indicating success/failure of api call
        --      x_msg_data                      - exception messages if any
        -- Notes
        --      None.
        PROCEDURE process_resp_doc(
                p_party_query_id                IN      VARCHAR2,
                p_query_success_flag            IN      VARCHAR2,
                p_ucc_doc_unique_id             IN      VARCHAR2,
                p_xmlg_internal_control_no      IN      NUMBER,
                p_doc_status                    IN      VARCHAR2,
                x_collab_detail_id              OUT     NOCOPY  VARCHAR2,
                x_return_status                 OUT     NOCOPY  VARCHAR2,
                x_msg_data                      OUT     NOCOPY  VARCHAR2 );




END m4u_party_query;

 

/
