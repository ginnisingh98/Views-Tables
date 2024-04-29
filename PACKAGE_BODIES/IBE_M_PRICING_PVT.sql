--------------------------------------------------------
--  DDL for Package Body IBE_M_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_M_PRICING_PVT" AS
/* $Header: IBEVMPLB.pls 120.0.12010000.3 2012/10/29 06:01:51 amaheshw ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   Ibe_M_Pricing_Pvt
  --
  -- PURPOSE
  --
  --
  -- NOTES
  --
  -- HISTORY
  --   08/10/03           JQU              Created
  --   10/Jan/11          amaheshw         Bug 10217112
  --   29/Oct/12          ytian            Bug 14789352
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_M_PRICING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVMPLB.pls';

-- bug 14789352
procedure parseInputTable (p_inTable IN QP_UTIL_PUB.PRICE_LIST_TBL,
                        p_Type     IN VARCHAR2,
                        p_keyString IN VARCHAR2,
                        p_number IN NUMBER,
                        x_QueryString OUT NOCOPY VARCHAR2)
  IS

l_id_str varchar2(2000);
 begin



   delete from IBE_TEMP_TABLE where key =p_keyString;

   FOR i IN 1..p_inTable.COUNT LOOP
      l_id_str := p_inTable(i).price_list_id;

      INSERT into IBE_TEMP_TABLE (KEY, NUM_VAL) VALUES (p_keyString,to_number(l_id_str));

 end loop;


     x_QueryString := 'SELECT NUM_VAL FROM IBE_TEMP_TABLE WHERE KEY = :'||p_number||'';


exception
 WHEN OTHERS then
 -- printDebug('Exception.....'||sqlerrm,'parseInput');
 Raise;
end parseInputTable;


--
-- Search price lists given the currency code and search criteria.
--
PROCEDURE Search_Price_List
  (
   p_currency_code                  IN VARCHAR2,
   p_search_by                      IN NUMBER,
   p_search_value                   IN VARCHAR2,
   x_pricelist_csr                  OUT NOCOPY pricing_cur_type
  )
IS
  l_pricelist_id_tbl QP_UTIL_PUB.PRICE_LIST_TBL;
  idx              BINARY_INTEGER := 0;
  l_stmt           VARCHAR2(1000);
  l_count          NUMBER;
/* Commented and added by amaheshw on 10.jan.11 Bug 10217112
  l_tmp_str        VARCHAR2(2000);
  l_query_str      VARCHAR2(2000);
*/
  l_tmp_str        VARCHAR2(4000);
  l_query_str      VARCHAR2(4000);
  l_key_str        VARCHAR2(15);
  l_delete_status  VARCHAR2(10);
--  l_pricelist_id_jtf_tbl JTF_NUMBER_TABLE;
BEGIN
  l_tmp_str := '';
  l_query_str  := '';
  l_key_str := 'PRC_LIST_IDS';

  QP_UTIL_PUB.GET_PRICE_LIST(l_currency_code=>p_currency_code,
                             l_pricing_effective_date=>sysdate,
                             l_agreement_id=>null,
			     l_price_list_tbl=>l_pricelist_id_tbl);

  l_count := l_pricelist_id_tbl.COUNT;

--  IF (l_count < 1000) THEN
/*   bug 14789352
    FOR i IN 1..l_pricelist_id_tbl.COUNT LOOP
      IF (i = 1) THEN
        l_tmp_str := l_tmp_str || l_pricelist_id_tbl(i).price_list_id;
      ELSE
        l_tmp_str := l_tmp_str || ',' ||  l_pricelist_id_tbl(i).price_list_id;
      END IF;
    END LOOP;

    IBE_LEAD_IMPORT_PVT.parseInput(l_tmp_str, 'NUM',l_key_str,1,l_query_str);
*/
    parseInputTable(l_pricelist_id_tbl, 'NUM',l_key_str,1,l_query_str);
    l_stmt := ' SELECT list_header_id, name, description, currency_code '||
              ' FROM QP_LIST_HEADERS_V ' ||
              ' WHERE list_header_id in ( ' || l_query_str || ')';

    IF (p_search_by = 1) THEN
      l_stmt := l_stmt || ' AND UPPER(name) like UPPER(:2) ';
    ELSIF (p_search_by = 2) THEN
      l_stmt := l_stmt || ' AND UPPER(description) like UPPER(:2) ';
    END IF;

    l_stmt := l_stmt || ' ORDER BY 2 ';
    OPEN x_pricelist_csr FOR l_stmt using l_key_str,p_search_value;
/*  ELSE
  -- loop through PL/SQL table to construct JTF table

    l_pricelist_id_jtf_tbl := JTF_NUMBER_TABLE();

    FOR i in 1..l_pricelist_id_tbl.COUNT LOOP
      l_pricelist_id_jtf_tbl.EXTEND();

      l_pricelist_id_jtf_tbl(i) := l_pricelist_id_tbl(i);
    END LOOP;

    l_stmt := ' SELECT list_header_id, name, description, currency_code '||
            ' FROM QP_LIST_HEADERS_V '||
            ' WHERE list_header_id in ' ||
            ' (SELECT T.column_value FROM TABLE(:price_list_id_tbl AS '||
            ' JTF_NUMBER_TABLE) T WHERE T.column_value > 0 AND ' ||
            ' T.column_value < 9.99E125)';

    IF (p_search_by = 1) THEN
      l_stmt := l_stmt || ' AND name like :1 ';

    ELSIF (p_search_by = 2) THEN
      l_stmt := l_stmt || ' AND description like :1 ' ;

    END IF;

    OPEN x_pricelist_csr FOR l_stmt USING l_pricelist_id_jtf_tbl;

  END IF;
*/

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   	  IBE_UTIL.debug(' ERROR G_EXC_ERROR =' || FND_API.G_RET_STS_ERROR);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      	  IBE_UTIL.debug(' ERROR G_RET_STS_UNEXP_ERROR =' || FND_API.G_RET_STS_UNEXP_ERROR);
   WHEN OTHERS THEN
         	  IBE_UTIL.debug(' ERROR G_RET_STS_UNEXP_ERROR =' || FND_API.G_RET_STS_UNEXP_ERROR);

        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	FND_MESSAGE.Set_Token('ROUTINE', 'Search_Price_List');
     	FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     	FND_MESSAGE.Set_Token('REASON', SQLERRM);
     	FND_MSG_PUB.Add;

END Search_Price_List;
PROCEDURE Search_Currency
  (
   p_search_by                      IN VARCHAR2,
   p_search_value                   IN VARCHAR2,
   x_currency_csr                  OUT NOCOPY currency_cur_type
  )
IS
    l_query_statement VARCHAR2(1000);

BEGIN
    QP_UTIL_PUB.GET_PRICE_LIST_CURRENCY(p_price_list_id => null,x_sql_string => l_query_statement);
    if p_search_by = 'currName' then
        open x_currency_csr FOR 'SELECT currency_code, name FROM('||l_query_statement||')WHERE LOWER(name) like :p_search_value' USING p_search_value;
    else
        open x_currency_csr FOR 'SELECT currency_code, name FROM(' ||l_query_statement|| ')WHERE LOWER(currency_code) like :p_search_value' USING p_search_value;
    end if;
END Search_Currency;

END Ibe_M_Pricing_Pvt;

/
