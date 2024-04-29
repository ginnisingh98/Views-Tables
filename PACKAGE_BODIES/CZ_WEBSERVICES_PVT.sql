--------------------------------------------------------
--  DDL for Package Body CZ_WEBSERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_WEBSERVICES_PVT" AS
/*  $Header: czwspvtb.pls 120.1 2005/06/17 11:49:15 dalee ship $        */
------------------------------------------------------------------------------------------
G_PKG_NAME   CONSTANT VARCHAR2(30) := 'CZ_WEBSERVICES_PVT';

procedure validate(p_init_msg        IN VARCHAR2
                  ,p_url             IN VARCHAR2
                  ,x_config_xml_msg  OUT NOCOPY VARCHAR2
                  ,x_return_status   OUT NOCOPY VARCHAR2
                  ,x_msg_count       OUT NOCOPY NUMBER
                  ,x_msg_data        OUT NOCOPY VARCHAR2
                  )
IS

  l_api_name CONSTANT VARCHAR2(20) := 'validate:ws';
  l_api_version  CONSTANT NUMBER := 1.0;
  l_empty_input_list CZ_CF_API.CFG_INPUT_LIST;
  l_empty_attr_list CZ_CF_API.config_ext_attr_tbl_type;
  l_config_message_pieces CZ_CF_API.CFG_OUTPUT_PIECES;
  l_validation_status NUMBER;
  l_rebuilt_xml VARCHAR2(4000);
  l_message_count NUMBER;
  l_message_data VARCHAR2(4000);

  BEGIN
   CZ_CF_API.validate(l_empty_input_list,
                      p_init_msg,
                      l_config_message_pieces,
                      l_validation_status,
                      p_url,
                      null);

    IF (l_validation_status = CZ_CF_API.CONFIG_PROCESSED) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (l_config_message_pieces.COUNT > 0) THEN
        l_rebuilt_xml := '';
        FOR i in l_config_message_pieces.FIRST..l_config_message_pieces.LAST LOOP
          -- THis keeps appending
          l_rebuilt_xml := l_rebuilt_xml || l_config_message_pieces(i);
        END LOOP;
        x_config_xml_msg := l_rebuilt_xml;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- need to put a message
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END validate; -- pvt

END;

/
