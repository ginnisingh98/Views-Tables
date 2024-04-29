--------------------------------------------------------
--  DDL for Package Body HR_XML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_XML_UTIL" as
/* $Header: hrxmlutl.pkb 120.1 2005/10/03 12:50:24 smallina noship $*/
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION value_Of
  (doc   in xmldom.DOMDocument
  ,xpath in varchar2
  )return varchar2 is
  retval varchar2(32767);
  --
Begin
  --
  if (not xmldom.IsNull(doc)) then
    xslprocessor.valueOf(xmlDom.makeNode(doc),xpath, retval);
  end if;
  return retval;
End value_Of;
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION value_Of
  (doc    in   CLOB
  ,xpath  in   varchar2
  ) return varchar2 is
  --
  retval varchar2(32767);
  xmldoc xmldom.DOMDocument;
  parser xmlparser.parser;
  --
Begin

  parser:=xmlparser.newParser;
  xmlparser.parseClob(parser,doc);
  xmldoc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  retval:=hr_xml_util.value_Of(xmldoc,xpath);
  xmldom.freeDocument(xmldoc);
  return retval;
exception
  when others then
    xmlparser.freeParser(parser);
    xmldom.freeDocument(xmldoc);
    return null;
End value_Of;
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION value_Of
  (doc   in   varchar2
  ,xpath in   varchar2
  ) return varchar2 is
  --
  retval varchar2(32767);
  xmldoc xmldom.DOMDocument;
  parser xmlparser.parser;
  --
Begin

  parser:=xmlparser.newParser;
  xmlparser.parseBuffer(parser,doc);
  xmldoc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  retval:=hr_xml_util.value_Of(xmldoc,xpath);
  xmldom.freeDocument(xmldoc);
  return retval;
Exception
  when others then
    xmlparser.freeParser(parser);
    xmldom.freeDocument(xmldoc);
    return null;
End value_Of;

--
-- -------------------------------------------------------------------------
-- |----------------------------< convert_CLOB_To_XMLDocument >---------------------------------|
-- -------------------------------------------------------------------------
--

FUNCTION convert_CLOB_To_XMLDocument(
  p_document in CLOB
  )return xmldom.DOMDocument is
  --
  x_xmlDocument xmldom.DOMDocument;
  l_parser      xmlparser.Parser;
Begin
   -- CLOB --> xmldom.DOMDocument
   l_parser 	:= xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   x_xmlDocument := xmlparser.getDocument(l_parser);
   xmlparser.freeParser(l_parser);
   return x_xmlDocument;
End convert_CLOB_To_XMLDocument;

--
-- -------------------------------------------------------------------------
-- |----------------------------< get_All_EOs_List >---------------------------------|
-- -------------------------------------------------------------------------
--

FUNCTION get_All_EOs_List
  (p_transaction_document in CLOB
  ) return xmlDOM.DOMNodeList is
  --
  l_parser xmlparser.Parser;
  -- xmlDOM.DOMNodeList
  l_TransCache_NodeList xmlDOM.DOMNodeList;
  l_EO_NodeList         xmlDOM.DOMNodeList;
  -- xmlDOM.DOMNode
  rootNode          xmlDOM.DOMNode;
  l_TransCache_Node xmlDOM.DOMNode;
  l_AM_Node         xmlDOM.DOMNode;
  l_TXN_Node        xmlDOM.DOMNode;
  --
Begin
  --
  l_parser 	:= xmlparser.newParser;
  rootNode	:= xmldom.makeNode(xmldom.getDocumentElement(convert_CLOB_To_XMLDocument(p_transaction_document)));
  -- Now get the <TransCache> Node
  l_TransCache_NodeList   :=xmldom.getChildrenByTagName(xmldom.makeElement(rootNode),'TransCache');
  l_TransCache_Node       :=xmldom.item(l_TransCache_NodeList,0);
  -- Now get the <AM> Node
  l_AM_Node               :=xmldom.getFirstChild(l_TransCache_Node);
  -- Now get the </cd> Node and get its Sibling --> <TXN>
  l_TXN_Node              :=xmldom.getNextSibling(xmldom.getFirstChild(l_AM_Node));
  l_EO_NodeList := xmldom.getElementsByTagName(xmldom.makeElement(l_TXN_Node),'EO');
  return l_EO_NodeList;
End get_All_EOs_List;

--
-- -------------------------------------------------------------------------
-- |----------------------------< test_Primary_Key >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION test_Primary_Key(
  p_EO_Row_Node xmldom.DOMNode
  ,p_primaryKey in varchar
  ,p_primarykey_Value  in varchar
  ) return boolean is
  x_match boolean;
  l_primary_key_NodeList xmldom.DOMNodeList;
  l_temp_Node xmldom.DOMNode;
  l_node_Value varchar2(1024);
Begin
  x_match :=false;
  -- Get the list of children whose name is =  p_primaryKey
  l_primary_key_NodeList := xmldom.getChildrenByTagName(xmldom.makeElement(p_EO_Row_Node),p_primaryKey);
  if (xmldom.getLength(l_primary_key_NodeList) > 0)  then
    for i in 1..xmldom.getLength(l_primary_key_NodeList) loop
      -- For each node in list extract its Text & compare with expected value
      l_temp_Node := xmldom.getFirstChild(xmldom.item(l_primary_key_NodeList,i-1));
      l_node_Value := xmldom.getNodeValue(l_temp_Node);
      -- if node's text matches expected value return true else continue
      if l_node_Value = p_primarykey_Value then
         return true;
      end if; -- End of if l_Node_Value = p_primarykey_Value
    end loop; -- End of for
  end if; -- End of main if

  return x_match;
End test_Primary_Key;

--
-- -------------------------------------------------------------------------
-- |----------------------------< check_Primary_Keys >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION check_Primary_Keys(
  p_EO_Row_Node xmldom.DOMNode
  ,p_pk_1 in varchar default null
  ,p_value_1  in varchar default null
  ,p_pk_2 in varchar default null
  ,p_value_2  in varchar default null
  ,p_pk_3 in varchar default null
  ,p_value_3  in varchar default null
  ,p_pk_4 in varchar default null
  ,p_value_4  in varchar default null
  ,p_pk_5 in varchar default null
  ,p_value_5  in varchar default null)
   return boolean is
  --
  TYPE primary_key_type IS TABLE of varchar2(1000) INDEX BY BINARY_INTEGER;
  TYPE expected_value_type IS TABLE of varchar2(1000) INDEX BY BINARY_INTEGER;
  --
  l_primaryKey_table primary_key_type;
  l_expected_value_table expected_value_type;
  --
  x_is_desiredNode boolean;
  --
  l_counter number(2);
Begin
  x_is_desiredNode := true;
  l_counter:=0;

  if p_pk_1 is not null and p_value_1 is not null then
    l_primaryKey_table(1):=p_pk_1;
    l_expected_value_table(1):=p_value_1;
    l_counter:= l_counter+1;
    if p_pk_2 is not null and p_value_2 is not null then
      l_primaryKey_table(2):=p_pk_2;
      l_expected_value_table(2):=p_value_2;
      l_counter:= l_counter+1;
      if p_pk_3 is not null and p_value_3 is not null then
          l_primaryKey_table(3):=p_pk_3;
          l_expected_value_table(3):=p_value_3;
          l_counter:= l_counter+1;
          if p_pk_4 is not null and p_value_4 is not null then
              l_primaryKey_table(4):=p_pk_4;
              l_expected_value_table(4):=p_value_4;
              l_counter:= l_counter+1;
              if p_pk_5 is not null and p_value_5 is not null then
                  l_primaryKey_table(5):=p_pk_5;
                  l_expected_value_table(5):=p_value_5;
                  l_counter:= l_counter+1;
              end if; --Pk5
          end if; --Pk4
      end if; --Pk3
    end if;--Pk2
  end if; --Pk1

  for i in 1..l_counter loop
    x_is_desiredNode :=test_Primary_Key(p_EO_Row_Node
                                     ,l_primaryKey_table(i)
                                     ,l_expected_value_table(i) );
    exit when x_is_desiredNode=false;
  end loop;

  return x_is_desiredNode;
End check_Primary_Keys;

--
-- -------------------------------------------------------------------------
-- |----------------------------< get_Node_Value >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_Node_Value
  (p_transaction_id     in    number
  ,p_desired_node_value in    varchar2
  ,p_xpath              in    varchar2
  ,p_EO_name            in    varchar    default null
  ,p_pk_1               in    varchar    default null
  ,p_value_1            in    varchar    default null
  ,p_pk_2               in    varchar    default null
  ,p_value_2            in    varchar    default null
  ,p_pk_3               in    varchar    default null
  ,p_value_3            in    varchar    default null
  ,p_pk_4               in    varchar    default null
  ,p_value_4            in    varchar    default null
  ,p_pk_5               in    varchar    default null
  ,p_value_5            in    varchar    default null
  )return varchar2 is
  -- Cursor to fetch the TXN_DOCUMENT
  cursor csr_trn is
    select transaction_document
    from hr_api_transactions
    where transaction_id = p_transaction_id;
  --
  txn_row   csr_trn%rowtype;
  --
Begin
  --
  open csr_trn;
  fetch csr_trn into txn_row;
  close csr_trn;

  if txn_row.transaction_document is not null then
    return get_Node_Value(txn_row.transaction_document
                          ,p_desired_node_value
                          ,p_xpath
                          ,p_EO_name
                          ,p_pk_1
                          ,p_value_1
                          ,p_pk_2
                          ,p_value_2
                          ,p_pk_3
                          ,p_value_3
                          ,p_pk_4
                          ,p_value_4
                          ,p_pk_5
                          ,p_value_5);

  end if;
  return null; -- The TXN Document is null so we are returning NULL
End get_Node_Value;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_Node_Value >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_Node_Value
  (p_transaction_document in CLOB
  ,p_desired_node_value in    varchar2
  ,p_xpath              in    varchar2
  ,p_EO_name            in    varchar    default null
  ,p_pk_1               in    varchar    default null
  ,p_value_1            in    varchar    default null
  ,p_pk_2               in    varchar    default null
  ,p_value_2            in    varchar    default null
  ,p_pk_3               in    varchar    default null
  ,p_value_3            in    varchar    default null
  ,p_pk_4               in    varchar    default null
  ,p_value_4            in    varchar    default null
  ,p_pk_5               in    varchar    default null
  ,p_value_5            in    varchar    default null
  )return varchar2 is
  -- xmlDOM.DOMNodeList
  l_EO_NodeList      xmlDOM.DOMNodeList;
  l_desired_NodeList xmlDOM.DOMNodeList;
  -- xmlDOM.DOMNode
  l_EO_Node      xmlDOM.DOMNode;
  l_EORowNode    xmlDOM.DOMNode;
  l_desired_Node xmlDOM.DOMNode;
  -- varchar2
  l_Node_Name    varchar2(1024);
  x_return_value varchar2(1024);
  -- Boolean
  l_is_desired_EORow boolean;

Begin
  x_return_value :=null;
  if p_transaction_document is not null and p_desired_node_value is not null then
    if p_EO_name is not null then
      -- get the list of all Children that are EOs
      l_EO_NodeList := get_All_EOs_List(p_transaction_document);

      if (xmldom.getLength(l_EO_NodeList) > 0)  then -- Some EOs are retrieved
        for i in 1..xmldom.getLength(l_EO_NodeList) loop
          l_EO_Node         :=xmldom.item(l_EO_NodeList,i-1);
          -- Get the Name of the EO
          l_Node_Name       :=xmldom.getAttribute(xmldom.makeElement(l_EO_Node),'Name');
          -- if it is the desired EO then proceed to filter else process next EONode
          if l_Node_Name =  p_EO_name then
            -- We get the Row Node with the assumption that there is only 1 EORow for an EO
            -- Later if we need to fetch Multiple EoRows we need do the following
            -- 1. Get the EORow identifier
            -- 2. xmldom.getChildrenByTagName(xmldom.makeElement(l_EO_Node),<mentiion the EORow identifier>);
            -- 3. Repeat the following steps for every EORow node.
            l_EORowNode		   := xmldom.getNextSibling(xmldom.getFirstChild(l_EO_Node));
            l_is_desired_EORow := check_Primary_Keys(l_EORowNode
                                                    ,p_pk_1
                                                    ,p_value_1
                                                    ,p_pk_2
                                                    ,p_value_2
                                                    ,p_pk_3
                                                    ,p_value_3
                                                    ,p_pk_4
                                                    ,p_value_4
                                                    ,p_pk_5
                                                    ,p_value_5);
            if l_is_desired_EORow = true then -- Checks if the EORow passes the primary key filter
              l_desired_NodeList := xmldom.getChildrenByTagName(xmldom.makeElement(l_EORowNode),p_desired_node_value);

              if (xmldom.getLength(l_desired_NodeList) > 0)  then -- Some Desired Nodes are Present
                l_desired_Node    := xmldom.item(l_desired_NodeList,0);
                l_desired_Node    := xmldom.getFirstChild(l_desired_Node);
                x_return_value    := xmldom.getNodeValue(l_desired_Node);
                return x_return_value;
              end if; -- End of if that checks if we have any Desired Nodes inside this EORow

            end if; -- End of if that Checks if the EORow passes the primary key filter
          end if; -- End of if that checks if EO name matches
        end loop; -- End of for loop
      end if;    -- Some EOs are retrieved
    else -- EO Name is null

      x_return_value:= value_Of(convert_CLOB_To_XMLDocument(p_transaction_document),(p_xpath ||'/' ||p_desired_node_value));
    end if; -- If for the EO Name
  end if; -- Main if

  return x_return_value; -- This place will be encountered only when no matches are there

EXCEPTION
  when others then
    return null;
End get_Node_Value;

--
-- -------------------------------------------------------------------------
-- |----------------------------< get_Transaction_Id >---------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_Transaction_Id
  (p_item_type   in varchar2
  ,p_item_key    in varchar2
  )return number is
  -- Cursor to select the Txn id
  -- From the table : HR_API_TRANSACTIONS
  cursor csr_hat is
    select transaction_id
    from hr_api_transactions
    where ITEM_KEY = p_item_key
    and ITEM_TYPE  = p_item_type;
  -- RowType
  hat_row  csr_hat%rowType;
Begin
  open  csr_hat;
  fetch  csr_hat into hat_row;
  close csr_hat;

  return hat_row.transaction_id;
End get_Transaction_Id;

--
-- -------------------------------------------------------------------------
-- |----------------------------< get_Primary_Keys >---------------------------------|
-- -------------------------------------------------------------------------
--

FUNCTION get_Primary_Keys
  (p_transaction_id    in      number
  ,p_object_type       in      varchar2
  ,p_object_name       in      varchar2
  ,p_row_Count             out nocopy number
  )return Primary_Key_Rec is
  -- Cursor to fetch the PKs
  cursor csr_hats is
   select pk1,pk2,pk3,pk4,pk5
   from hr_api_transaction_steps
   where transaction_id=p_transaction_id
   and  OBJECT_TYPE = p_object_type
   and  OBJECT_NAME = p_object_name;
  -- Number
  l_row_count number(10);
  l_csr_hat csr_hats%rowtype;
Begin
  p_row_Count :=null;
  l_row_count :=0;
  for l_csr_hat in csr_hats loop
    pk_rec.primary_Key1(l_row_count+1) := l_csr_hat.pk1;
    pk_rec.primary_Key2(l_row_count+1) := l_csr_hat.pk2;
    pk_rec.primary_Key3(l_row_count+1) := l_csr_hat.pk3;
    pk_rec.primary_Key4(l_row_count+1) := l_csr_hat.pk4;
    pk_rec.primary_Key5(l_row_count+1) := l_csr_hat.pk5;
    l_row_count :=l_row_count+1;
  end loop;
  -- Set the number of rows fetched in the out parameter
  p_row_Count :=  l_row_count;
  -- Return the Record of Primary Keys
  return pk_rec;
End get_Primary_Keys;

END hr_xml_util;

/
