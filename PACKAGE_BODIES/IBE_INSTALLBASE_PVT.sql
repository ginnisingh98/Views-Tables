--------------------------------------------------------
--  DDL for Package Body IBE_INSTALLBASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_INSTALLBASE_PVT" AS
/* $Header: IBEVINSTB.pls 120.3 2005/11/24 04:23:47 cshivaru noship $ */
PROCEDURE Get_Connected_Instances(
            p_instance_id IN NUMBER,
            p_owner_party_id IN NUMBER,
            p_owner_party_account_id IN NUMBER,
            p_key_bind_value IN NUMBER,
            x_parse_key OUT NOCOPY VARCHAR2,
            x_query_inst_id OUT NOCOPY VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_count OUT NOCOPY NUMBER,
            x_return_message OUT NOCOPY VARCHAR2
          )
IS
    l_config_query_table csi_cz_int.config_query_table;
    l_config_pair_table csi_cz_int.config_pair_table;

    l_config_inst_header_id  number;
    l_config_inst_revision_number number;
    l_true VARCHAR2(1);

    CURSOR c_connected_to_inst_id
    (c_inst_hdr_id IN NUMBER, c_inst_rev_num IN NUMBER, c_inst_item_id IN NUMBER)
    IS
    SELECT INST.INSTANCE_ID
    FROM CSI_ITEM_INSTANCES INST
    WHERE INST.OWNER_PARTY_ID = p_owner_party_id
    AND INST.OWNER_PARTY_ACCOUNT_ID = p_owner_party_account_id
    AND INST.CONFIG_INST_HDR_ID = c_inst_hdr_id
    AND INST.CONFIG_INST_REV_NUM = c_inst_rev_num
    AND INST.CONFIG_INST_ITEM_ID = c_inst_item_id ;

    l_instance_id VARCHAR2(20);
    l_instance_string VARCHAR2(1000);
BEGIN
    l_instance_string := null;
    l_true := FND_API.G_TRUE;
    x_parse_key := '';
    -- Get the config inst header id and config inst revision number for
    -- this instance id.
    SELECT CSII.CONFIG_INST_HDR_ID, CSII.CONFIG_INST_REV_NUM
    INTO l_config_inst_header_id, l_config_inst_revision_number
    FROM CSI_ITEM_INSTANCES CSII
    WHERE CSII.INSTANCE_ID = p_instance_id;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_config_inst_header_id : '||l_config_inst_header_id);
        IBE_Util.Debug('l_config_inst_revision_number : '||l_config_inst_revision_number);
    END IF;


    l_config_query_table(0).config_header_id :=  l_config_inst_header_id ;
    l_config_query_table(0).config_revision_number := l_config_inst_revision_number ;

    --Call Instance Base API to get all the connected instances.
    csi_cz_int.get_connected_configurations(
            p_config_query_table => l_config_query_table,
            p_instance_level => 'INSTALLED',
            x_config_pair_table => l_config_pair_table,
            x_return_status => x_return_status,
            x_return_message => x_return_message
        );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('After Call to CSI API::x_return_status:'||x_return_status);
    END IF;

    -- If Ret Status is true and there is atleast one connected-to instance
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
        -- then construct a comma separated string of Instance Id
        IF l_config_pair_table.first is not null THEN

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('Ret Status is success and config pair table exists l_config_pair_table.first is not null');
            END IF;

            FOR l_iteration in l_config_pair_table.first .. l_config_pair_table.last
            LOOP
                IF ( l_config_pair_table(l_iteration).object_header_id is not null and
                     l_config_pair_table(l_iteration).subject_header_id is not null)
                THEN
                    OPEN c_connected_to_inst_id(l_config_pair_table(l_iteration).root_header_id,l_config_pair_table(l_iteration).root_revision_number,l_config_pair_table(l_iteration).root_item_id);
                    FETCH c_connected_to_inst_id into l_instance_id;
                    IF (l_instance_string is null) THEN
                        l_instance_string := l_instance_id;
                    ELSE
                        l_instance_string := l_instance_string||','||l_instance_id;
                    END IF;
                    CLOSE c_connected_to_inst_id;
                END IF;
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_Util.Debug('l_iteration::'||l_iteration||'l_instance_string::'||l_instance_string);
                END IF;
            END LOOP;
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('After Loop : l_instance_string :: '||l_instance_string);
        END IF;
        -- If there is atleast one Connected-to Instance
        IF(l_instance_string is not null)
        THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('Inside if bef call to lead import');
            END IF;
            -- Initialise key and call the API to put the values in the temp table
            -- Out var would be a query which can be used with the key bound to
            -- value of p_number
            x_parse_key := 'PARSE_INSTANCE_IDS';
            IBE_LEAD_IMPORT_PVT.parseInput(
                    p_inString => l_instance_string,
                    p_type => 'CHAR',
                    p_keyString => x_parse_key,
                    p_number => p_key_bind_value,
                    x_QueryString => x_query_inst_id
            );
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('After call to parse Input,x_QueryString : '||x_query_inst_id);
            END IF;
        END IF;
    ELSE
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Return Status is not successful, Message : '||x_return_message);
        END IF;
    END IF;

    EXCEPTION
    WHEN others THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Exception caught : ' ||sqlerrm);
        RAISE;
    END IF;
END Get_Connected_Instances;

FUNCTION IS_ITEM_IN_MSITE(
                             p_inventory_item_id IN NUMBER,
                             p_minisite_id IN NUMBER
                         )
RETURN VARCHAR2
IS
l_return_value VARCHAR2(1);
l_true VARCHAR2(1);
BEGIN
    l_true := FND_API.G_TRUE;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('IS_ITEM_IN_MSITE BEGIN ');
    END IF;

    l_return_value := 'N'; -- Initialize return value to be N.

    -- If inventory item id and minisite id is passed
    IF(p_inventory_item_id is not null and p_minisite_id is not null)
    THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('p_inventory_item_id : '||p_inventory_item_id||' :: p_minisite_id : '||p_minisite_id);
        END IF;

    SELECT 'Y' INTO l_return_value -- Set return val to Y if item exists in Msite
    FROM  DUAL
    WHERE EXISTS
    (
        SELECT si.inventory_item_id
        FROM ibe_dsp_msite_sct_items msi, ibe_dsp_section_items si
        WHERE  msi.section_item_id = si.section_item_id
        AND msi.mini_site_id = p_minisite_id
	AND si.inventory_item_id = p_inventory_item_id
    );

    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Retrun Value : '||l_return_value);
    END IF;

    RETURN(l_return_value);
    -- Handle any exception, return 'N'
    EXCEPTION
    WHEN OTHERS THEN
    BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Exception caught'||sqlerrm);
    END IF;
        RETURN(l_return_value) ;
    END;
END IS_ITEM_IN_MSITE;

END IBE_INSTALLBASE_PVT;

/
