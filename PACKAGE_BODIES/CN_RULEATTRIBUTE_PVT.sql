--------------------------------------------------------
--  DDL for Package Body CN_RULEATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULEATTRIBUTE_PVT" AS
--$Header: cnvratrb.pls 120.6 2006/06/08 15:01:42 hanaraya ship $

--Global Variables
G_PKG_NAME             CONSTANT VARCHAR2(30) := 'CN_RuleAttribute_PVT';
G_API_NAME             VARCHAR2(30);


PROCEDURE  Check_Attr_types
         (p_value_1           IN  VARCHAR2 := NULL,
          p_value_2           IN  VARCHAR2 := NULL,
          p_column_id         IN  NUMBER,
          p_rule_id           IN  NUMBER   := NULL,
          p_ruleset_id        IN  NUMBER   := NULL,
          p_org_id            IN  NUMBER,
          p_data_flag	      IN  VARCHAR2,
          p_loading_status    IN  VARCHAR2,
          x_loading_status    OUT NOCOPY VARCHAR2)  IS

    l_api_name                   VARCHAR2(30) := 'Check_Attr_Types';

  cursor get_cn_obj_curs IS
   SELECT *
      FROM cn_objects
     WHERE object_id = p_column_id
       AND table_id IN (-11803,-16134) AND
       ORG_ID=p_org_id;

   l_value       cn_attribute_rules.column_value%TYPE;
   l_date_value  DATE;

  cursor get_rules IS
   SELECT name
      FROM cn_rules
     WHERE rule_id = p_rule_id
       AND ruleset_id = p_ruleset_id AND
       ORG_ID=p_org_id;

  cursor get_rulesets IS
   SELECT name
      FROM cn_rulesets
     WHERE ruleset_id = p_ruleset_id AND
     ORG_ID=p_org_id;


   l_ruleset_name  cn_rulesets.name%TYPE;
   l_rule_name     cn_rules.name%TYPE;

   cn_obj_recs  get_cn_obj_curs%ROWTYPE;

BEGIN

   x_loading_status := p_loading_status;

   --Check to see if the attribute rule exists

   open get_cn_obj_curs;
   fetch get_cn_obj_curs into cn_obj_recs;
   close get_cn_obj_curs;

   open get_rules ;
   fetch get_rules into l_rule_name;
   close get_rules ;

   open get_rulesets ;
   fetch get_rulesets into l_ruleset_name;
   close get_rulesets ;


  IF p_data_flag = 'O'
  THEN
     IF cn_obj_recs.column_datatype = 'NUMB' THEN
        Begin
         l_value := to_number(nvl(p_value_1,'0'));
        exception
             when  value_error then
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name('CN', 'CN_DATATYPE_VALUE_MISMATCH');
                   fnd_message.set_token('CLASSIFICATION_RULE_NAME', l_ruleset_name);
                   fnd_message.set_token('RULE_NAME', l_rule_name);
                   fnd_message.set_token('COLUMN_NAME', cn_obj_recs.user_name);
                   fnd_msg_pub.add;
                END IF;
                x_loading_status := 'CN_DATATYPE_VALUE_MISMATCH';
        end ;

    ELSIF cn_obj_recs.column_datatype = 'DATE' THEN

        Begin
         l_date_value := nvl(to_date(p_value_1,'DD/MM/RRRR'),sysdate);
        exception
             when  others then
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name('CN', 'CN_DATATYPE_VALUE_MISMATCH');
                   fnd_message.set_token('CLASSIFICATION_RULE_NAME', l_ruleset_name);
                   fnd_message.set_token('RULE_NAME', l_rule_name);
                   fnd_message.set_token('COLUMN_NAME', cn_obj_recs.user_name);
                   fnd_msg_pub.add;
                END IF;
                x_loading_status := 'CN_DATATYPE_VALUE_MISMATCH';
        end ;

    END IF;

  ELSIF p_data_flag = 'R'
  THEN

     IF cn_obj_recs.column_datatype = 'NUMB' THEN
        Begin
         l_value := to_number(nvl(p_value_1,'0'));
         l_value := to_number(nvl(p_value_2,'0'));
        exception
             when  value_error then
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name('CN', 'CN_DATATYPE_VALUE_MISMATCH');
                   fnd_message.set_token('CLASSIFICATION_RULE_NAME', l_ruleset_name);
                   fnd_message.set_token('RULE_NAME', l_rule_name);
                   fnd_message.set_token('COLUMN_NAME', cn_obj_recs.user_name);
                   fnd_msg_pub.add;
                END IF;
                x_loading_status := 'CN_DATATYPE_VALUE_MISMATCH';
                RAISE FND_API.G_EXC_ERROR;
        end ;

    ELSIF cn_obj_recs.column_datatype = 'DATE' THEN

        Begin
         l_date_value := nvl(to_date(p_value_1,'DD/MM/RRRR'),sysdate);
         l_date_value := nvl(to_date(p_value_2,'DD/MM/RRRR'),sysdate);
        exception
             when  others then
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                THEN
                   fnd_message.set_name('CN', 'CN_DATATYPE_VALUE_MISMATCH');
                   fnd_message.set_token('CLASSIFICATION_RULE_NAME', l_ruleset_name);
                   fnd_message.set_token('RULE_NAME', l_rule_name);
                   fnd_message.set_token('COLUMN_NAME', cn_obj_recs.user_name);
                   fnd_msg_pub.add;
                END IF;
                x_loading_status := 'CN_DATATYPE_VALUE_MISMATCH';
        end ;

    END IF;

END IF;

END Check_Attr_types;


function get_operator(l_attribute_rule_id NUMBER,l_org_id NUMBER) return varchar2
is
l_lowValue    varchar2(240);
l_highValue   varchar2(240);
l_columnValue varchar2(240);
l_operatorValue varchar2(100);
l_notflag varchar2(100);

x_attribute_rule_id number(10);
x_org_id number(10);

CURSOR getOperator(c_attribute_rule_id NUMBER,c_org_id NUMBER)
IS
select
low_value,
high_value,
column_value,
not_flag
from cn_attribute_rules where attribute_rule_id=c_attribute_rule_id and org_id=c_org_id;


begin
x_attribute_rule_id :=l_attribute_rule_id;
x_org_id := l_org_id;

For getOperatorCursor in getOperator(x_attribute_rule_id,x_org_id)
loop
l_highValue := getOperatorCursor.high_value;
l_lowValue := getOperatorCursor.low_value;
l_columnValue := getOperatorCursor.column_value;
l_notflag := getOperatorCursor.not_flag;
end loop;

if(l_columnValue is not null) then
   if(l_notflag is not null and l_notflag = 'N') then
   l_operatorValue:='EQUALS';
   else
   l_operatorValue:='NOT_EQUALS';
   end if;
end if;

if(l_highValue is not null and l_columnValue is null) then
   if(l_notflag is not null and l_notflag='N') then
   l_operatorValue :='BETWEEN' ;
   else
   l_operatorValue :='NOT_BETWEEN';
   end if;
end if;

return l_operatorValue;
end;


function get_rendered(l_attribute_rule_id NUMBER,l_org_id NUMBER) return number
is
l_lowValue    varchar2(240);
l_highValue   varchar2(240);
l_columnValue varchar2(240);
l_rendered    number(1);
l_notflag varchar2(100);

x_attribute_rule_id number(10);
x_org_id number(10);

CURSOR getOperator(c_attribute_rule_id NUMBER,c_org_id NUMBER)
IS
select
low_value,
high_value,
column_value,
not_flag
from cn_attribute_rules where attribute_rule_id=c_attribute_rule_id and org_id=c_org_id;


begin
l_rendered := 1;
x_attribute_rule_id :=l_attribute_rule_id;
x_org_id := l_org_id;

For getOperatorCursor in getOperator(x_attribute_rule_id,x_org_id)
loop
l_highValue := getOperatorCursor.high_value;
l_lowValue := getOperatorCursor.low_value;
l_columnValue := getOperatorCursor.column_value;
l_notflag := getOperatorCursor.not_flag;
end loop;


if(l_highValue is not null and l_columnValue is null) then
l_rendered := 0;
end if;

return l_rendered;
end;


--=============================================================================
-- Function Name  : Check_AttributeRuleParameters
-- Purpose        : Check if the attribute rule fields conform to the
--                  required standards
-- Parameters     :
-- IN             : p_attribute_rule_name  IN VARCHAR2         Required
--                  p_not_flag             IN VARCHAR2         Required
--                  p_value_1              IN VARCHAR2         Required
--                  p_value_2              IN VARCHAR2         Required
--                  p_data_flag            IN VARCHAR2         Required
--                  p_object_name          IN VARCHAR2         Required
--                  p_rule_id              IN NUMBER           Required
-- OUT            :
-- History
--   10-AUG-98  Ram Kalyanasundaram      Created
--=============================================================================
FUNCTION  Check_AttributeRuleParameters
        (p_not_flag  IN cn_attribute_rules.not_flag%TYPE := FND_API.G_MISS_CHAR,
         p_value_1   IN VARCHAR2                           := FND_API.G_MISS_CHAR,
         p_value_2   IN VARCHAR2                          := FND_API.G_MISS_CHAR,
         p_data_flag IN VARCHAR2                          := FND_API.G_MISS_CHAR,
         p_object_name IN cn_objects.name%TYPE,
         p_rule_id     IN cn_rules.rule_id%TYPE,
	 p_org_id      IN cn_attribute_rules.org_id%TYPE,
         p_attribute_rule_id IN  cn_attribute_rules.attribute_rule_id%TYPE := NULL,
         x_attribute_rule_id OUT NOCOPY cn_attribute_rules.attribute_rule_id%TYPE,
         p_loading_status IN  VARCHAR2,
         x_loading_status OUT NOCOPY VARCHAR2)  RETURN VARCHAR2 IS

  l_api_name                   VARCHAR2(30) := 'Check_AttributeRuleParameters';
  l_dim_hierarchy_id           NUMBER := 0;
  l_counter                    NUMBER := 0;
  l_object_column              NUMBER := 0;
  l_hierarchy_value            NUMBER := 0;
  l_not_flag		       VARCHAR2(30);

BEGIN

   x_loading_status := p_loading_status;
   l_not_flag       := p_not_flag;

  IF p_data_flag = FND_API.G_MISS_CHAR
     OR
     p_data_flag IS NULL
  THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_RULE_ATTR_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULE_ATTR_TYPE';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_data_flag NOT IN ('O', 'H', 'R')
  THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_RULE_ATTR_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_RULE_ATTR_TYPE';
      RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF p_data_flag = 'O' AND
      ((p_value_1 = FND_API.g_miss_char) OR (p_value_1 IS NULL)) OR
      ((p_object_name = FND_API.g_miss_char) OR (p_object_name IS NULL))
    THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_PARAM_ONE_VAL');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_PARAM_ONE_VAL';
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_data_flag IN ('R', 'H') AND
      ((p_value_1 = FND_API.G_MISS_CHAR OR p_value_2 = FND_API.G_MISS_CHAR) OR
        (p_value_1 IS NULL OR p_value_2 IS NULL)))
    THEN
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_PARAM_R_H');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_PARAM_R_H';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF  l_not_flag  = FND_API.G_MISS_CHAR THEN

      l_not_flag :=  NULL;
  END IF;

  --Check to see if the attribute rule exists
  BEGIN
    SELECT object_id
      INTO l_object_column
      FROM cn_objects
     WHERE name = p_object_name AND org_id=p_org_id
       AND table_id IN (-11803,-16134);
  EXCEPTION
    WHEN no_data_found then
           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_INVALID_OBJECT_NAME');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_INVALID_OBJECT_NAME';
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF p_data_flag = 'O'
  THEN

   -- Added on 24/SEP/01
    SELECT COUNT(*)
      INTO l_counter
      FROM cn_attribute_rules
     WHERE column_id = l_object_column
       AND column_value = p_value_1
       AND rule_id = p_rule_id and org_id=p_org_id
       AND   ((p_attribute_rule_id IS NOT NULL AND
                attribute_rule_id <> p_attribute_rule_id)
               OR
               (p_attribute_rule_id IS NULL))
       AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar

    --
    -- Commented on 01/03/02
    -- Kumar Sivasankaran
    --
    --IF l_counter = 1
    --THEN
    --  SELECT attribute_rule_id
    --    INTO x_attribute_rule_id
    --    FROM cn_attribute_rules
    --   WHERE column_id = l_object_column
    --     AND column_value = p_value_1
    --     AND rule_id = p_rule_id and org_id=p_org_id
    --     AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar;

    --END IF;

  ELSIF p_data_flag = 'R'
  THEN


   -- Added on 24/SEP/01
   -- Kumar Sivasankaran
   BEGIN

     IF p_value_1 IS NOT NULL AND
       p_value_2 IS NOT NULL AND
       to_number(p_value_2) < to_number(p_value_1) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_HIGH_LOW');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_HIGH_LOW';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   EXCEPTION
    WHEN value_error THEN
        null;
    END;

    SELECT COUNT(*)
      INTO l_counter
      FROM cn_attribute_rules
     WHERE column_id = l_object_column
       AND low_value = p_value_1
       AND high_value = p_value_2
       and org_id=p_org_id
      AND rule_id = p_rule_id
      AND   ((p_attribute_rule_id IS NOT NULL AND
                attribute_rule_id <> p_attribute_rule_id)
               OR
               (p_attribute_rule_id IS NULL))
      AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar;

    --IF l_counter = 1
    --THEN
     --
    -- Commented on 01/03/02
    -- Kumar Sivasankaran
    --
    --  SELECT attribute_rule_id
    --    INTO x_attribute_rule_id
    --    FROM cn_attribute_rules
    --   WHERE column_id = l_object_column
    --     AND low_value = p_value_1
    --     AND high_value = p_value_2
    --     AND rule_id = p_rule_id
    --     AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar;

    --END IF;

  ELSIF p_data_flag = 'H'
  THEN

   BEGIN

    --SELECT head_hierarchy_id
    --  INTO l_dim_hierarchy_id
    --  FROM cn_head_hierarchies
    -- WHERE name = p_value_1;

    SELECT head_hierarchy_id
      INTO l_dim_hierarchy_id
      FROM cn_head_hierarchies
     WHERE head_hierarchy_id = p_value_1 and org_id=p_org_id;

    EXCEPTION
    WHEN no_data_found then
           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_HIERARCHY_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_HIERARCHY_NOT_FOUND';
      RAISE FND_API.G_EXC_ERROR;
  END;

  BEGIN

    SELECT hn.value_id
      INTO l_hierarchy_value
      FROM cn_hierarchy_nodes hn,
           cn_dim_hierarchies dh
     --WHERE hn.name = p_value_2
     WHERE hn.value_id = p_value_2
       AND   hn.dim_hierarchy_id = dh.dim_hierarchy_id
       and hn.org_id=dh.org_id
       and hn.org_id=p_org_id
       AND dh.header_dim_hierarchy_id = l_dim_hierarchy_id;

  EXCEPTION
    WHEN no_data_found then
           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_HIERARCHY_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_HIERARCHY_NOT_FOUND';
      RAISE FND_API.G_EXC_ERROR;
  END;


    SELECT COUNT(*)
      INTO l_counter
      FROM cn_attribute_rules
     WHERE column_id = l_object_column
       AND dimension_hierarchy_id = l_dim_hierarchy_id
       AND column_value = l_hierarchy_value
       AND rule_id = p_rule_id
       and org_id=p_org_id
        AND   ((p_attribute_rule_id IS NOT NULL AND
                attribute_rule_id <> p_attribute_rule_id)
               OR
               (p_attribute_rule_id IS NULL))
       AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar;

    --
    -- Commented on 01/03/02
    -- Kumar Sivasankaran
    --
    --IF l_counter = 1
    --THEN
    --  SELECT attribute_rule_id
    --    INTO x_attribute_rule_id
    --    FROM cn_attribute_rules
    --   WHERE column_id = l_object_column
    --     AND dimension_hierarchy_id = l_dim_hierarchy_id
    --     AND column_value = l_hierarchy_value
    --     AND rule_id = p_rule_id
    --     AND not_flag = nvl(l_not_flag,not_flag) ; -- Added Kumar;
    --END IF;
  END IF;

  IF l_counter > 0
  THEN
      --Error condition
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_MULTIPLE_ATTRIBUTES');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_MULTIPLE_ATTRIBUTES';
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Added on 01/03/02
  -- Kumar Sivasankaran

  IF p_attribute_rule_id IS NOT NULL THEN

     x_attribute_rule_id := p_attribute_rule_id;

  END IF;


  RETURN fnd_api.g_false;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RETURN fnd_api.g_true;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      RETURN fnd_api.g_true;

   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      RETURN fnd_api.g_true;
END Check_AttributeRuleParameters;

--=============================================================================
-- Start of comments
--        API name         : Create_RuleAttribute
--        Type                : Private
--        Function        : This Private API can be used to create a rule,
--                          a ruleset or rule attributes.
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                                p_rule_rec      IN
--                                                  CN_RuleAttribute_PVT.rule_rec_type
--                              p_RuleAttribute_rec IN
--                                        CN_RuleAttribute_PVT.RuleAttribute_rec_type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : Note text
--
-- End of comments
--=============================================================================
PROCEDURE Create_RuleAttribute
( p_api_version                   IN        NUMBER,
  p_init_msg_list                IN        VARCHAR2 := FND_API.G_FALSE,
  p_commit                            IN          VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN          NUMBER         := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY        VARCHAR2,
  x_msg_count                        OUT NOCOPY        NUMBER,
  x_msg_data                        OUT NOCOPY        VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_RuleAttribute_rec               IN OUT NOCOPY  CN_RuleAttribute_PVT.RuleAttribute_rec_type
)
IS

  l_api_name                        CONSTANT VARCHAR2(30)        := 'Create_RuleAttribute';
  l_api_version                   CONSTANT NUMBER         := 1.0;
  l_attr_rule_retvalue          NUMBER;
  l_dim_hierarchy_id            cn_head_hierarchies.head_hierarchy_id%TYPE;
  l_hierarchy_value             cn_hierarchy_nodes.value_id%TYPE;
  l_rowid                        VARCHAR2(4000);
  l_sequence_number                NUMBER;
  l_attribute_rule_ret_value    NUMBER;
  l_count                       NUMBER;
  l_object_id                   NUMBER;
  l_attribute_rule_id                NUMBER;
  l_ruleset_status		VARCHAR2(100);

  G_LAST_UPDATE_DATE     DATE                  := Sysdate;
  G_LAST_UPDATED_BY      NUMBER                := fnd_global.user_id;
  G_CREATION_DATE        DATE                  := Sysdate;
  G_CREATED_BY           NUMBER                := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN    NUMBER                := fnd_global.login_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Create_RuleAttribute;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
     THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   -- API body


   --Check for missing parameters
   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.ruleset_id,
         cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.rule_id,
         cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   /* This shouldn't be here. select from sequence
   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.attribute_rule_id,
         cn_api.get_lkup_meaning('RULE_ATTRIBUTE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;
   */

   IF (cn_api.chk_null_char_para
       ( p_RuleAttribute_rec.object_name,
         cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( p_RuleAttribute_rec.data_flag,
         cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF Check_AttributeRuleParameters
     (p_RuleAttribute_rec.not_flag,
      p_RuleAttribute_rec.value_1,
      p_RuleAttribute_rec.value_2,
      p_RuleAttribute_rec.data_flag,
      p_RuleAttribute_rec.object_name,
      p_RuleAttribute_rec.rule_id,
      p_RuleAttribute_rec.org_id,
      null,
      l_attribute_rule_id,
      x_loading_status,
      x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT object_id
     INTO l_object_id
     FROM cn_objects
     WHERE name = p_RuleAttribute_rec.object_name and
     org_id=p_RuleAttribute_rec.org_id
     AND table_id IN (-11803,-16134);

   SELECT Nvl(p_RuleAttribute_rec.attribute_rule_id, cn_attribute_rules_s.NEXTVAL)
     INTO l_attribute_rule_id
     FROM dual;

   IF p_RuleAttribute_rec.data_flag IN (  'O' , 'R') THEN
      Check_Attr_types
         (p_value_1           => p_RuleAttribute_rec.value_1,
          p_value_2           => p_RuleAttribute_rec.value_2,
          p_column_id         => l_object_id,
          p_rule_id           => p_RuleAttribute_rec.rule_id,
          p_ruleset_id        => p_RuleAttribute_rec.ruleset_id,
          p_org_id            => p_RuleAttribute_rec.org_id,
          p_data_flag	      => p_RuleAttribute_rec.data_flag,
          p_loading_status    => x_loading_status,
          x_loading_status    => x_loading_status) ;

         if x_loading_status = 'CN_DATATYPE_VALUE_MISMATCH' THEN
         RAISE fnd_api.g_exc_error;
         END IF;

   END IF;

   IF p_RuleAttribute_rec.data_flag = 'O'
     THEN
      cn_syin_attr_rules_pkg.insert_row
        (l_attribute_rule_id,
         l_object_id,
         p_RuleAttribute_rec.value_1,
         NULL,
         NULL,
         NULL,
         p_RuleAttribute_rec.not_flag,
         p_RuleAttribute_rec.rule_id,
         p_RuleAttribute_rec.ruleset_id,
         g_last_update_date,
         g_last_updated_by,
         g_creation_date,
         g_created_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
    ELSIF p_RuleAttribute_rec.data_flag = 'R'
      THEN
      cn_syin_attr_rules_pkg.insert_row
        (l_attribute_rule_id,
         l_object_id,
         NULL,
         p_RuleAttribute_rec.value_1,
         p_RuleAttribute_rec.value_2,
         NULL,
         p_RuleAttribute_rec.not_flag,
         p_RuleAttribute_rec.rule_id,
         p_RuleAttribute_rec.ruleset_id,
         g_last_update_date,
         g_last_updated_by,
         g_creation_date,
         g_created_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
    ELSIF p_RuleAttribute_rec.data_flag = 'H'
      THEN
      SELECT head_hierarchy_id
        INTO l_dim_hierarchy_id
        FROM cn_head_hierarchies
        --WHERE name = p_RuleAttribute_rec.value_1;
        WHERE head_hierarchy_id = p_RuleAttribute_rec.value_1 and org_id=p_RuleAttribute_rec.org_id;
      SELECT hn.value_id
        INTO l_hierarchy_value
        FROM cn_hierarchy_nodes hn,
        cn_dim_hierarchies dh
        --WHERE hn.name = p_RuleAttribute_rec.value_2
        WHERE hn.value_id = p_RuleAttribute_rec.value_2
        AND hn.dim_hierarchy_id = dh.dim_hierarchy_id
        AND dh.header_dim_hierarchy_id = l_dim_hierarchy_id
	AND hn.org_id=dh.org_id
	AND hn.org_id=p_RuleAttribute_rec.org_id;

      cn_syin_attr_rules_pkg.insert_row
        (l_attribute_rule_id,
         l_object_id,
         l_hierarchy_value,
         NULL,
         NULL,
         l_dim_hierarchy_id,
         p_RuleAttribute_rec.not_flag,
         p_RuleAttribute_rec.rule_id,
         p_RuleAttribute_rec.ruleset_id,
         g_last_update_date,
         g_last_updated_by,
         g_creation_date,
         g_created_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
   END IF;

   -- End of API body.

    -- Added the Code to unsync the rules if any rules added deleted or update
    -- Added by Kumar Sivasankaran
    -- Date: 01/30/02
    --
     cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_RuleAttribute_rec.ruleset_id,
                                    x_ruleset_status_in => l_ruleset_status,
				    x_org_id =>p_RuleAttribute_rec.org_id);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Create_RuleAttribute;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Create_RuleAttribute;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                x_loading_status := 'UNEXPECTED_ERR';
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
        WHEN OTHERS THEN
                ROLLBACK TO Create_RuleAttribute;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                x_loading_status := 'UNEXPECTED_ERR';
                  IF         FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
END Create_RuleAttribute;


--=============================================================================
-- Start of comments
--        API name         : Update_RuleAttribute
--        Type                : Private
--        Function        : This Private API can be used to update a rule,
--                          a ruleset or rule attributes in Oracle Sales
--                          Compensation.
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                                p_rule_rec_type      IN
--                                                  CN_RuleAttribute_PVT.rule_rec_type
--                              p_RuleAttribute_rec_type IN
--                                        CN_RuleAttribute_PVT.RuleAttribute_rec_type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : Note text
--
-- End of comments
--=============================================================================

PROCEDURE Update_RuleAttribute
  ( p_api_version                   IN        NUMBER,
    p_init_msg_list                IN        VARCHAR2 := FND_API.G_FALSE,
    p_commit                            IN          VARCHAR2 := FND_API.G_FALSE,
    p_validation_level                IN          NUMBER         := FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT NOCOPY        VARCHAR2,
    x_msg_count                        OUT NOCOPY        NUMBER,
    x_msg_data                        OUT NOCOPY        VARCHAR2,
    x_loading_status              OUT NOCOPY     VARCHAR2,
    p_old_RuleAttribute_rec           IN OUT NOCOPY  CN_RuleAttribute_PVT.RuleAttribute_rec_type,
    p_RuleAttribute_rec           IN OUT NOCOPY  CN_RuleAttribute_PVT.RuleAttribute_rec_type
    ) IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_RuleAttribute';
   l_api_version               CONSTANT NUMBER := 1.0;
   l_attr_rule_retvalue        NUMBER;
   l_dim_hierarchy_id          cn_head_hierarchies.head_hierarchy_id%TYPE;
   l_hierarchy_value           cn_hierarchy_nodes.value_id%TYPE;
   l_rowid                     VARCHAR2(4000);
   l_sequence_number           NUMBER;
   l_attribute_rule_ret_value  NUMBER;
   l_count                     NUMBER;
   l_object_id                 NUMBER;
   l_attribute_rule_id         NUMBER;
   l_ruleset_status 	       VARCHAR2(100);

   l_object_version_number     cn_attribute_rules.object_version_number%TYPE;

  G_LAST_UPDATE_DATE     DATE                  := Sysdate;
  G_LAST_UPDATED_BY      NUMBER                := fnd_global.user_id;
  G_CREATION_DATE        DATE                  := Sysdate;
  G_CREATED_BY           NUMBER                := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN    NUMBER                := fnd_global.login_id;

  CURSOR l_ovn_csr IS
    SELECT object_version_number
      FROM cn_attribute_rules
      WHERE attribute_rule_id = p_ruleattribute_rec.attribute_rule_id
      AND ruleset_id = p_ruleattribute_rec.ruleset_id
      AND rule_id = p_ruleattribute_rec.rule_id
      AND ORG_ID=p_RuleAttribute_rec.org_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Update_RuleAttribute;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                p_api_version,
                                                l_api_name,
                                                G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
     THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- API body

   --Check for missing parameters in the p_rule_rec parameter
   IF (cn_api.chk_miss_null_num_para
       ( p_old_RuleAttribute_rec.ruleset_id,
         cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_num_para
       ( p_old_RuleAttribute_rec.rule_id,
         cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_num_para
       ( p_old_RuleAttribute_rec.attribute_rule_id,
         cn_api.get_lkup_meaning('RULE_ATTRIBUTE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( p_old_RuleAttribute_rec.object_name,
         cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( p_old_RuleAttribute_rec.data_flag,
         cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   --New Parameter
   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.ruleset_id,
         cn_api.get_lkup_meaning('RULESET_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.rule_id,
         cn_api.get_lkup_meaning('RULE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_miss_null_num_para
       ( p_RuleAttribute_rec.Attribute_rule_id,
         cn_api.get_lkup_meaning('RULE_ATTRIBUTE_ID', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( p_RuleAttribute_rec.object_name,
         cn_api.get_lkup_meaning('OBJECT_NAME', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.chk_null_char_para
       ( p_RuleAttribute_rec.data_flag,
         cn_api.get_lkup_meaning('DATA_FLAG', 'RULESET_TYPE'),
         x_loading_status,
         x_loading_status) = FND_API.G_TRUE )
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;


   -- check if the object version number is the same
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version_number;
   CLOSE l_ovn_csr;

   if (l_object_version_number <>
     p_ruleattribute_rec.object_version_number) THEN

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
      THEN
         fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
         fnd_msg_pub.add;
      END IF;

      x_loading_status := 'CN_INVALID_OBJECT_VERSION';
      RAISE FND_API.G_EXC_ERROR;

   end if;


   IF Check_AttributeRuleParameters
     (p_RuleAttribute_rec.not_flag,
      p_RuleAttribute_rec.value_1,
      p_RuleAttribute_rec.value_2,
      p_RuleAttribute_rec.data_flag,
      p_RuleAttribute_rec.object_name,
      p_RuleAttribute_rec.rule_id,
      p_RuleAttribute_rec.org_id,
      p_RuleAttribute_rec.attribute_rule_id,
      l_attribute_rule_id,
      x_loading_status,
      x_loading_status) = fnd_api.g_true
     THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT object_id
     INTO l_object_id
     FROM cn_objects
     WHERE name = p_RuleAttribute_rec.object_name AND org_id=p_RuleAttribute_rec.org_id
     AND table_id IN (-11803,-16134);

   IF p_RuleAttribute_rec.data_flag IN (  'O' , 'R') THEN
      Check_Attr_types
         (p_value_1           => p_RuleAttribute_rec.value_1,
          p_value_2           => p_RuleAttribute_rec.value_2,
          p_column_id         => l_object_id,
          p_rule_id           => p_RuleAttribute_rec.rule_id,
          p_ruleset_id        => p_RuleAttribute_rec.ruleset_id,
          p_org_id            => p_RuleAttribute_rec.org_id,
          p_data_flag	      => p_RuleAttribute_rec.data_flag,
          p_loading_status    => x_loading_status,
          x_loading_status    => x_loading_status) ;

         if x_loading_status = 'CN_DATATYPE_VALUE_MISMATCH' THEN
         RAISE fnd_api.g_exc_error;
         END IF;
   END IF;

   IF p_RuleAttribute_rec.data_flag = 'O'
     THEN
      cn_syin_attr_rules_pkg.update_row
         (/*l_attribute_rule_id*/ p_old_RuleAttribute_rec.attribute_rule_id,
         p_RuleAttribute_rec.object_version_number,
         l_object_id,
         p_RuleAttribute_rec.value_1,
         NULL,
         NULL,
         NULL,
         p_RuleAttribute_rec.not_flag,
         g_last_update_date,
         g_last_updated_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
    ELSIF p_RuleAttribute_rec.data_flag = 'R'
      THEN

      cn_syin_attr_rules_pkg.update_row
        (p_old_RuleAttribute_rec.attribute_rule_id ,
         p_RuleAttribute_rec.object_version_number,
         l_object_id,
         NULL,
         p_RuleAttribute_rec.value_1,
         p_RuleAttribute_rec.value_2,
         NULL,
         p_RuleAttribute_rec.not_flag,
         g_last_update_date,
         g_last_updated_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
    ELSIF p_RuleAttribute_rec.data_flag = 'H'
      THEN

     BEGIN

      -- Modified By Kumar
      SELECT head_hierarchy_id
        INTO l_dim_hierarchy_id
        FROM cn_head_hierarchies
      WHERE head_hierarchy_id = p_RuleAttribute_rec.value_1
      AND org_id=p_RuleAttribute_rec.org_id;

     EXCEPTION

     WHEN no_data_found then
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_HIERARCHY_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;
      x_loading_status := 'CN_HIERARCHY_NOT_FOUND';
      RAISE FND_API.G_EXC_ERROR;

     END ;

     BEGIN

      SELECT hn.value_id
        INTO l_hierarchy_value
        FROM cn_hierarchy_nodes hn,
        cn_dim_hierarchies dh
        WHERE hn.value_id = p_RuleAttribute_rec.value_2
        AND hn.dim_hierarchy_id = dh.dim_hierarchy_id
        AND dh.header_dim_hierarchy_id = l_dim_hierarchy_id
	AND hn.org_id=dh.org_id
	AND hn.org_id=p_RuleAttribute_rec.org_id;

      EXCEPTION

      WHEN no_data_found then
          IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
         fnd_message.set_name('CN', 'CN_HIERARCHY_NOT_FOUND');
         fnd_msg_pub.add;
      END IF;
        x_loading_status := 'CN_HIERARCHY_NOT_FOUND';
        RAISE FND_API.G_EXC_ERROR;

      END ;

      cn_syin_attr_rules_pkg.update_row
        (p_old_RuleAttribute_rec.attribute_rule_id,
         p_RuleAttribute_rec.object_version_number,
         l_object_id,
         l_hierarchy_value,
         NULL,
         NULL,
         l_dim_hierarchy_id,
         p_RuleAttribute_rec.not_flag,
         g_last_update_date,
         g_last_updated_by,
         g_last_update_login,
	 p_RuleAttribute_rec.org_id);
   END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit )
     THEN
      COMMIT WORK;
   END IF;


    -- Added the Code to unsync the rules if any rules added deleted or update
    -- Added by Kumar Sivasankaran
    -- Date: 01/30/02
    --
    cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_RuleAttribute_rec.ruleset_id,
                                    x_ruleset_status_in => l_ruleset_status,
				    x_org_id =>p_RuleAttribute_rec.org_id);


   -- Standard call to get message count and if count is 1, get message info.
          FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_RuleAttribute;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (p_count                 =>      x_msg_count,
         p_data                  =>      x_msg_data,
         p_encoded              =>      fnd_api.g_false
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_RuleAttribute;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (p_count                 =>      x_msg_count,
         p_data                  =>      x_msg_data,
         p_encoded              =>      fnd_api.g_false
         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_RuleAttribute;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF         FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME,
            l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count                 =>      x_msg_count,
         p_data                  =>      x_msg_data,
         p_encoded              =>      fnd_api.g_false
         );

END;
--=============================================================================
-- Start of comments
--        API name         : Delete_RuleAttribute
--        Type                : Private
--        Function        : This Private API can be used to delete a rule or
--                          it's attributes from Oracle Sales Compensation.
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                                p_rule_rec_type      IN
--                                                  CN_RuleAttribute_PVT.rule_rec_type
--                              p_rule_attr_rec_type IN
--                                        CN_RuleAttribute_PVT.rule_attr_rec_type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : This can be used to delete rules (and thus
--                          their rule attributes).
--                          Mandatory parameters are ruleset id, rule id
--                          and attribute_rule_id
--
-- End of comments
--=============================================================================

PROCEDURE Delete_RuleAttribute
( p_api_version             IN   NUMBER,
  p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  x_loading_status          OUT NOCOPY  VARCHAR2,
  p_ruleset_id              IN   cn_attribute_rules.ruleset_id%TYPE,
  p_rule_id                 IN   cn_attribute_rules.rule_id%TYPE,
  p_attribute_rule_id       IN   cn_attribute_rules.attribute_rule_id%TYPE,
  p_object_version_number   IN   cn_attribute_rules.object_version_number%TYPE
) IS


   l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_RuleAttribute';
  l_api_version                 CONSTANT number := 1.0;

  l_count                       NUMBER;
  l_org_id                      NUMBER;

  l_ruleset_status 		VARCHAR2(100);

  l_object_version_number       cn_attribute_rules.object_version_number%TYPE;

  G_LAST_UPDATE_DATE     DATE                  := Sysdate;
  G_LAST_UPDATED_BY      NUMBER                := fnd_global.user_id;
  G_CREATION_DATE        DATE                  := Sysdate;
  G_CREATED_BY           NUMBER                := fnd_global.user_id;
  G_LAST_UPDATE_LOGIN    NUMBER                := fnd_global.login_id;

  CURSOR l_ovn_csr IS
    SELECT object_version_number
      FROM cn_attribute_rules
      WHERE attribute_rule_id = p_attribute_rule_id
      AND ruleset_id = p_ruleset_id
      AND rule_id = p_rule_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_RuleAttribute;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (         l_api_version,
                                                    p_api_version,
                                                       l_api_name,
                                                    G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  --Validate that a rule attribute exists for the specified ruleset_id, rule_id
  --and attribute_rule_id

  SELECT COUNT(1)
    INTO l_count
    FROM cn_rule_attr_expression
    WHERE ((operand1 = p_attribute_rule_id
            AND operand1_ra_rae_flag = 'RA')
           OR
           (operand2 = p_attribute_rule_id
            AND operand2_ra_rae_flag = 'RA'))
    AND rule_id = p_rule_id;

  IF l_count <> 0
    THEN
     --Error condition
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
       THEN
        fnd_message.set_name('CN', 'CN_EXPRESSION_EXISTS');
        fnd_msg_pub.add;
     END IF;

     x_loading_status := 'CN_EXPRESSION_EXISTS';
     RAISE FND_API.G_EXC_ERROR;

  END IF;

    SELECT COUNT(1)
    INTO l_count
    FROM cn_attribute_rules
    WHERE attribute_rule_id = p_attribute_rule_id
    AND ruleset_id = p_ruleset_id
    AND rule_id = p_rule_id;

    select org_id into l_org_id
    FROM cn_attribute_rules
    WHERE attribute_rule_id = p_attribute_rule_id
    AND ruleset_id = p_ruleset_id
    AND rule_id = p_rule_id;

  IF l_count <> 1
    THEN
     --Error condition
     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
       THEN
        fnd_message.set_name('CN', 'CN_INVALID_ATTRIBUTE_RULE');
        fnd_msg_pub.add;
     END IF;

     x_loading_status := 'CN_INVALID_ATTRIBUTE_RULE';
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  -- check if the object version number is the same
  OPEN l_ovn_csr;
  FETCH l_ovn_csr INTO l_object_version_number;
  CLOSE l_ovn_csr;

  if (l_object_version_number <> p_object_version_number) THEN

     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
       THEN
        fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
        fnd_msg_pub.add;
     END IF;

     x_loading_status := 'CN_INVALID_OBJECT_VERSION';
     RAISE FND_API.G_EXC_ERROR;
  end if;

  cn_syin_attr_rules_pkg.delete_row(p_attribute_rule_id);

    -- Added the Code to unsync the rules if any rules added deleted or update
    -- Added by Kumar Sivasankaran
    -- Date: 01/30/02
    --
     cn_rulesets_pkg.Unsync_ruleset(x_ruleset_id_in => p_ruleset_id,
                                    x_ruleset_status_in => l_ruleset_status,
				    x_org_id =>l_org_id);

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Delete_RuleAttribute;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Delete_RuleAttribute;
                x_loading_status := 'UNEXPECTED_ERR';
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
        WHEN OTHERS THEN
                ROLLBACK TO Delete_RuleAttribute;
                x_loading_status := 'UNEXPECTED_ERR';
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                  IF         FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name
                            );
                END IF;
                FND_MSG_PUB.Count_And_Get
                    (p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data,
                 p_encoded              =>      fnd_api.g_false
                    );
END;

FUNCTION get_valuset_query (l_valueset_id NUMBER) RETURN VARCHAR2 IS
    l_valueset_r   fnd_vset.valueset_r;
    l_table_r      fnd_vset.table_r;
    l_valueset_dr  fnd_vset.valueset_dr;
    l_select_stmt  VARCHAR2(4000);
    l_select       VARCHAR2(4000);
    l_from         VARCHAR2(4000);
    l_where        VARCHAR2(4000);
  BEGIN
    -- get the SQL statement for the record qroup
    fnd_vset.get_valueset(l_valueset_id, l_valueset_r, l_valueset_dr);
    l_select  := l_valueset_r.table_info.value_column_name ||' column_name, ' ||
     		      NVL(l_valueset_r.table_info.id_column_name, 'null') || ' column_id, ' ||
                  NVL(l_valueset_r.table_info.meaning_column_name, 'null') || ' column_meaning';

    l_from :=  l_valueset_r.table_info.table_name;

    IF l_valueset_r.table_info.where_clause IS NULL THEN
     l_where := ' ';
    ELSE
     l_where := l_valueset_r.table_info.where_clause;
    END IF;

   l_select_stmt := 'Select ' || l_select || ' from ' || l_from || ' ' || l_where ;

   return l_select_stmt;
END;



 --=======================================================================
  -- Procedure Name:    get_attr_valueset
  -- Purpose
 --=======================================================================
  PROCEDURE get_attr_valueset
                (p_column_id    IN  NUMBER,
                 p_column_name  IN  VARCHAR2,
		 p_org_id       IN NUMBER,
                 x_select       OUT NOCOPY VARCHAR2,
                 x_from         OUT NOCOPY VARCHAR2,
                 x_where        OUT NOCOPY VARCHAR2) IS

    l_valueset_r   fnd_vset.valueset_r;
    l_table_r      fnd_vset.table_r;
    l_valueset_dr  fnd_vset.valueset_dr;
    l_select_stmt  VARCHAR2(4000);
    l_valueset_id  cn_objects.value_set_id%TYPE;

    l_count        NUMBER := 0;
    lov_return     BOOLEAN;
    l_ret          INTEGER;
    l_cursor_num   INTEGER;

    CURSOR c_get_valueset_id IS
     SELECT value_set_id
     FROM   cn_objects
     WHERE  object_id   = p_column_id
     AND    name        = p_column_name
     AND    object_type = 'COL'
     AND org_id=p_org_id
     AND    value_set_id IS NOT NULL;


  BEGIN

     OPEN c_get_valueset_id;
     FETCH c_get_valueset_id INTO l_valueset_id;
     IF c_get_valueset_id%FOUND THEN

        -- get the SQL statement for the record qroup
        fnd_vset.get_valueset(l_valueset_id, l_valueset_r, l_valueset_dr);

        IF l_valueset_r.table_info.where_clause IS NULL
          THEN
           x_select  := NVL(l_valueset_r.table_info.id_column_name,
                        l_valueset_r.table_info.value_column_name)
                        ||' column_id , '
                        ||l_valueset_r.table_info.value_column_name
                        ||' column_name ';

               --added the following for bugfix#3155283
	       --allows to search using meaning also

		x_select := x_select || ', ' || NVL(l_valueset_r.table_info.meaning_column_name,
			 l_valueset_r.table_info.value_column_name) || ' meaning ' ;

		x_from :=  l_valueset_r.table_info.table_name;

                x_where := ' WHERE 1 = 1 ';

	  ELSE

                        x_select:= NVL(l_valueset_r.table_info.id_column_name,
                        l_valueset_r.table_info.value_column_name)
                        ||' column_id , '
                        ||l_valueset_r.table_info.value_column_name
                        ||' column_name ';

               --added the following for bugfix#3155283
	       --allows to search using meaning also

		x_select := x_select || ', ' || NVL(l_valueset_r.table_info.meaning_column_name,
			 l_valueset_r.table_info.value_column_name) || ' meaning ' ;

	  	x_from :=  l_valueset_r.table_info.table_name;

		x_where := l_valueset_r.table_info.where_clause;
          END IF;




          -- check to see if the select statement is a valid one.
          BEGIN
            l_select_stmt := 'Select ' || x_select ||
                             ' from ' || x_from ||
			     ' ' || x_where ;

            l_cursor_num := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor_num,l_select_stmt,2);
            l_ret := dbms_sql.execute(l_cursor_num);
          EXCEPTION
             WHEN OTHERS THEN
              x_select := ' 1 column_id , 2 column_name ';
              x_from   := ' dual ';
              x_where  := ' 1 = 2 ';

          END ;
          dbms_sql.close_cursor(l_cursor_num);

        CLOSE c_get_valueset_id;

    ELSE
      x_select := ' 1 column_id , 2 column_name ';
              x_from   := ' dual ';
              x_where  := ' 1 = 2 ';

    END IF;

  END get_attr_valueset;



END CN_RuleAttribute_PVT;

/
