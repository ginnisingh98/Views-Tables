--------------------------------------------------------
--  DDL for Package CSI_GENERIC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_GENERIC_GRP" AUTHID CURRENT_USER AS
/* $Header: csiggens.pls 115.9 2003/10/01 21:37:42 jpwilson ship $ */
    --
    --
    g_pkg_name              VARCHAR2(30) := 'CSI_GENERIC_GRP';
    --
    FUNCTION CONFIG_ROOT_NODE (p_instance_id             IN  NUMBER ,
                               p_relationship_type_code  IN  VARCHAR2
                           )
          RETURN NUMBER;
         PRAGMA RESTRICT_REFERENCES( config_root_node, WNDS, WNPS);

    -- This function is used by mass_edit form CSIMEDIT.fmb
    -- This should not be used by other products
    FUNCTION R_COUNT ( l_select IN VARCHAR2 )
        RETURN NUMBER;

    -- This procedure can be used to perform validations before inserting a record
    -- into csi_i_extended_attribs.

    PROCEDURE Create_extended_attrib(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_ext_attrib_rec             IN     csi_datastructures_pub.ext_attrib_rec,
    x_attribute_id               OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2);

    -- This function is used by systems form UI.

    FUNCTION ui_system_rec
    RETURN csi_datastructures_pub.system_rec;

    -- This function is used by form UI.

    FUNCTION ui_transaction_rec
    RETURN csi_datastructures_pub.transaction_rec;

    -- This function is used by form UI.

    FUNCTION ui_ext_attrib_query_rec
    RETURN csi_datastructures_pub.extend_attrib_query_rec;

   -- This function is used by form UI.

    FUNCTION ui_relationship_query_rec
    RETURN csi_datastructures_pub.relationship_query_rec;

  -- this routine is used by the terminate customer products conc program

  PROCEDURE terminate_instances(
    errbuf      OUT NOCOPY VARCHAR2,
    retcode     OUT NOCOPY NUMBER,
    p_status_id IN  NUMBER);

END CSI_GENERIC_GRP;

 

/
