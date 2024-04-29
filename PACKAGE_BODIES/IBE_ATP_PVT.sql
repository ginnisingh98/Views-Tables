--------------------------------------------------------
--  DDL for Package Body IBE_ATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ATP_PVT" AS
/* $Header: IBEVATPB.pls 115.17 2003/08/29 09:08:49 nsultan ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'IBE_ATP_PVT';

  PROCEDURE Check_Availability (
    p_quote_header_id              IN            NUMBER,
    p_date_format                  IN            VARCHAR2,
    p_lang_code                    IN            VARCHAR2,
    x_error_flag                   OUT NOCOPY    VARCHAR2,
    x_error_message                OUT NOCOPY    VARCHAR2,
    x_atp_line_tbl                 IN OUT NOCOPY ATP_Line_Tbl_Typ
  )
  IS

    c_api_version CONSTANT NUMBER       := 1.0;
    c_api_name    CONSTANT VARCHAR2(30) := 'Check_Availability';

    l_date_format                    VARCHAR2(30);
    l_lang_code                      VARCHAR2(10);

    l_qte_line_tbl                   ASO_QUOTE_PUB.qte_line_tbl_type;
    l_shipment_tbl                   ASO_QUOTE_PUB.shipment_tbl_type;
    l_atp_tbl                        ASO_ATP_INT.atp_tbl_typ;
    i                                BINARY_INTEGER;
    j                                BINARY_INTEGER;

    l_quote_line_id                  NUMBER;
    l_organization_id                NUMBER;
    l_inventory_item_id              NUMBER;
    l_quantity                       NUMBER;
    l_uom_code                       VARCHAR2(3);
    l_request_date                   DATE;
    l_sysdate                        DATE;

    l_return_status                  VARCHAR2(1);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(4000);
    l_error_message                  VARCHAR2(4000);

    E_IBE_ATP_BAD_DATE_FMT           EXCEPTION;
    E_IBE_ATP_NO_PREV_DATE           EXCEPTION;

    l_ship_site_use_id               NUMBER;
    Cursor get_site_use_id(l_party_site_id number) is
           select site_use.site_use_id
           from hz_party_sites party_site,
                hz_cust_acct_sites_all acct_site,
                hz_cust_site_uses_all site_use
           where party_site.party_site_id = acct_site.party_site_id
           and   acct_site.cust_acct_site_id = site_use.cust_acct_site_id
           and   party_site.party_site_id = l_party_site_id;

  BEGIN

    x_error_flag    := 'N';
    x_error_message := '';

    -- Make sure p_date_format and p_lang_code have meaningful values:
    --
    IF (p_date_format IS NULL OR LENGTH(p_date_format) = 0) THEN
      l_date_format := 'DD-MON-RRRR';
    ELSE
      l_date_format := p_date_format;
    END IF;

    IF (p_lang_code IS NULL OR LENGTH(p_lang_code) = 0) THEN
      l_lang_code := NVL(USERENV('LANG'), 'US');
    ELSE
      l_lang_code := p_lang_code;
    END IF;

    -- Always initialize API return message list:
    --
    FND_MSG_PUB.Initialize;

    -- Capture sysdate to be used as default need-by date:
    --
    -- Changed for performace
    -- SELECT SYSDATE INTO l_sysdate FROM DUAL;
    l_sysdate := SYSDATE;

    -- Populate quote line and shipment tables:
    --
    i := x_atp_line_tbl.FIRST;
    j := 1;
    LOOP

      l_qte_line_tbl(j).quote_header_id :=
        p_quote_header_id;
      l_qte_line_tbl(j).quote_line_id :=
        x_atp_line_tbl(i).quote_line_id;
      l_qte_line_tbl(j).organization_id :=
        x_atp_line_tbl(i).organization_id;
      l_qte_line_tbl(j).inventory_item_id :=
        x_atp_line_tbl(i).inventory_item_id;
      l_qte_line_tbl(j).quantity :=
        x_atp_line_tbl(i).quantity;
      l_qte_line_tbl(j).uom_code :=
        x_atp_line_tbl(i).uom_code;

      -- Check whether Customer Id and site id are not null. If yes, then
      -- get Site_use_id.
      -- pass null for ship to cust account id and ship party site id if
      -- site_use_id is null OR customer Id and site Id are null.
      -- In that case ASO api will pass default Customer Id and site Use Id
      IF x_atp_line_tbl(i).customer_id IS NOT NULL AND
         x_atp_line_tbl(i).ship_to_site_id IS NOT NULL THEN
           l_shipment_tbl(j).ship_to_cust_account_id :=
                 x_atp_line_tbl(i).customer_id;
         -- Get Site Use Id from party_site_id. ASO_SHIPMENTS_V stores
         -- Party_site_is instead of site_use_id.
            open get_site_use_id(x_atp_line_tbl(i).ship_to_site_id);
            fetch get_site_use_id into l_ship_site_use_id;
            IF get_site_use_id%FOUND THEN
               l_shipment_tbl(j).ship_to_party_site_id := l_ship_site_use_id;
            ELSE
               l_shipment_tbl(j).ship_to_party_site_id := NULL;
	       l_shipment_tbl(j).ship_to_cust_account_id := NULL;
            END IF;
            close get_site_use_id;
      ELSE
           l_shipment_tbl(j).ship_to_party_site_id := NULL;
           l_shipment_tbl(j).ship_to_cust_account_id := NULL;
      END IF;
      l_shipment_tbl(j).ship_method_code :=
         x_atp_line_tbl(i).ship_method_code;

      IF (x_atp_line_tbl(i).request_date IS NULL OR
          x_atp_line_tbl(i).request_date = '') THEN
        l_shipment_tbl(j).request_date := l_sysdate;
        BEGIN
          x_atp_line_tbl(i).request_date := TO_CHAR(l_sysdate, l_date_format);
        EXCEPTION
          WHEN OTHERS THEN
            x_error_message := SQLERRM;
            RAISE E_IBE_ATP_BAD_DATE_FMT;
        END;
      ELSE
        BEGIN
          l_shipment_tbl(j).request_date :=
            TO_DATE(x_atp_line_tbl(i).request_date, l_date_format);
        EXCEPTION
          WHEN OTHERS THEN
            x_error_message := SQLERRM;
            RAISE E_IBE_ATP_BAD_DATE_FMT;
        END;
      END IF;

      IF x_atp_line_tbl(i).request_date IS NOT NULL AND
         to_date(x_atp_line_tbl(i).request_date,l_date_format) < to_date(l_sysdate,l_date_format) THEN
         RAISE E_IBE_ATP_NO_PREV_DATE;
      END IF;

      IF i < x_atp_line_tbl.LAST THEN
        i := x_atp_line_tbl.NEXT(i);
        j := j + 1;
      ELSE
        EXIT;
      END IF;

    END LOOP;

    -- Check availability:
    --
    ASO_ATP_INT.Check_ATP (
      p_api_version_number => c_api_version,
      p_init_msg_list      => FND_API.G_TRUE,
      p_qte_line_tbl       => l_qte_line_tbl,
      p_shipment_tbl       => l_shipment_tbl,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_atp_tbl            => l_atp_tbl
    );

    -- Standard check for error:
    --
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Copy results back into x_atp_line_tbl:
    --
    IF l_atp_tbl.COUNT = x_atp_line_tbl.COUNT THEN

      i := l_atp_tbl.FIRST;
      j := x_atp_line_tbl.FIRST;

      LOOP

        -- Get quantity available on the date requested:
        --
        x_atp_line_tbl(j).request_date_quantity :=
          l_atp_tbl(i).request_date_quantity;

        -- Get earliest date on which requested quantity is available:
        --
        BEGIN
          x_atp_line_tbl(j).available_date :=
            TO_CHAR(l_atp_tbl(i).ship_date, l_date_format);
        EXCEPTION
          WHEN OTHERS THEN
            x_error_message := SQLERRM;
            RAISE E_IBE_ATP_BAD_DATE_FMT;
        END;

        -- Get error code:
        --
        x_atp_line_tbl(j).error_code := l_atp_tbl(i).error_code;

        -- If error, get error message; if message is NULL, look it up:
        --
        IF l_atp_tbl(i).error_code <> 0 THEN

          IF (l_atp_tbl(i).message IS NOT NULL AND
              LENGTH(l_atp_tbl(i).message) > 0)
          THEN
            x_atp_line_tbl(j).error_message := l_atp_tbl(i).message;
          ELSE
            BEGIN
              SELECT meaning
                INTO x_atp_line_tbl(j).error_message
                FROM fnd_lookup_values
                WHERE language = l_lang_code
                  AND view_application_id = 700
                  AND security_group_id =
                        fnd_global.lookup_security_group(lookup_type,
                                                         view_application_id)
                  AND lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
                  AND TO_NUMBER(lookup_code) = l_atp_tbl(i).error_code;
            EXCEPTION
              WHEN OTHERS THEN
                x_atp_line_tbl(j).error_message := 'Unknown error';
            END;
          END IF;

        END IF;

        IF i < l_atp_tbl.LAST THEN
          i := l_atp_tbl.NEXT(i);
          j := x_atp_line_tbl.NEXT(j);
        ELSE
          EXIT;
        END IF;

      END LOOP;

    ELSE

      -- Rowcount mismatch:
      --
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    RETURN;

  EXCEPTION

    WHEN E_IBE_ATP_BAD_DATE_FMT THEN
      x_error_flag    := 'Y';
      x_error_message := 'Date format error ('||x_error_message||')';

    WHEN E_IBE_ATP_NO_PREV_DATE THEN
      x_error_flag   := 'Y';
      x_error_message := 'No previous date ('||x_error_message||')';

    WHEN FND_API.G_EXC_ERROR THEN
      x_error_flag    := 'Y';
      x_error_message :=  null;--'ASO_ATP_INT internal error. ';
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        LOOP
          l_error_message := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
          IF l_error_message IS NULL THEN
            EXIT;
          ELSE
            x_error_message := x_error_message||l_error_message||' ';
          END IF;
        END LOOP;
      ELSIF l_msg_count = 1 THEN
        x_error_message := x_error_message||l_msg_data;
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_error_flag    := 'Y';
      x_error_message := 'ASO_ATP_INT unexpected internal error. ';
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        LOOP
          l_error_message := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
          IF l_error_message IS NULL THEN
            EXIT;
          ELSE
            x_error_message := x_error_message||l_error_message||' ';
          END IF;
        END LOOP;
      ELSIF l_msg_count = 1 THEN
        x_error_message := x_error_message||l_msg_data;
      END IF;

    WHEN OTHERS THEN
      x_error_flag    := 'Y';
      x_error_message := 'IBE_ATP_PVT unexpected internal error. ';
      FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
      FND_MESSAGE.Set_Token('ROUTINE', c_api_name);
      FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
      FND_MESSAGE.Set_Token('REASON', SQLERRM);
      FND_MSG_PUB.Add;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, c_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        LOOP
          l_error_message := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
          IF l_error_message IS NULL THEN
            EXIT;
          ELSE
            x_error_message := x_error_message||l_error_message||' ';
          END IF;
        END LOOP;
      ELSIF l_msg_count = 1 THEN
        x_error_message := x_error_message||l_msg_data;
      END IF;

  END Check_Availability;

END IBE_ATP_PVT;

/
