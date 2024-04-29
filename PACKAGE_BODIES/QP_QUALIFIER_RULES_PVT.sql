--------------------------------------------------------
--  DDL for Package Body QP_QUALIFIER_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFIER_RULES_PVT" AS
/* $Header: QPXVQRQB.pls 120.2 2005/07/06 02:59:19 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Qualifier_Rules_PVT';

--  Qualifier_Rules

PROCEDURE Qualifier_Rules
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_old_QUALIFIER_RULES_rec       OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
l_p_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
l_old_QUALIFIER_RULES_rec     QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_old_QUALIFIER_RULES_rec;
BEGIN

       oe_debug_pub.add('entering qualifier rules' );
       oe_debug_pub.add('operation is '||nvl(l_QUALIFIER_RULES_rec.operation,'null') );

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_QUALIFIER_RULES_rec.operation
    ,   p_control_rec   => p_control_rec
    );



    --  Set record return status.

    l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_QUALIFIER_RULES_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        --oe_debug_pub.add('setting missing old record to null');

        l_old_QUALIFIER_RULES_rec :=
        QP_Qualifier_Rules_Util.Convert_Miss_To_Null (l_old_QUALIFIER_RULES_rec);

    ELSIF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_QUALIFIER_RULES_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM
        THEN

            l_old_QUALIFIER_RULES_rec := QP_Qualifier_Rules_Util.Query_Row
            (   p_qualifier_rule_id           => l_QUALIFIER_RULES_rec.qualifier_rule_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_QUALIFIER_RULES_rec :=
            QP_Qualifier_Rules_Util.Convert_Miss_To_Null (l_old_QUALIFIER_RULES_rec);

        END IF;

        --  Complete new record from old

        l_QUALIFIER_RULES_rec := QP_Qualifier_Rules_Util.Complete_Record
        (   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        ,   p_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
        );

    END IF;

    --  Attribute level validation.

    -- added on 30-nov-99 by svdeshmu to avoid generation of sequence
    -- number for qualifier rule id when lines are added for existing
    --qualifier rule

    IF    l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_CREATE OR
          l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_UPDATE OR
          l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

           --oe_debug_pub.add('executing QP_validate.attributes');
		 --oe_debug_pub.add('name '||l_QUALIFIER_RULES_rec.name);
		 --oe_debug_pub.add('desc '||l_QUALIFIER_RULES_rec.description);



		 --oe_debug_pub.add('from old record');
		 --oe_debug_pub.add('name '||l_old_QUALIFIER_RULES_rec.name);
		 --oe_debug_pub.add('desc '||l_old_QUALIFIER_RULES_rec.description);

           --dbms_output.put_line('calling validate attributes');

            QP_Validate_Qualifier_Rules.Attributes
            (   x_return_status               => l_return_status
            ,   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
            ,   p_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
            );



    --oe_debug_pub.add('after executing QP_validate.attributes ,status is '|| l_return_status);
    --dbms_output.put_line('after executing QP_validate.attributes ,status is '|| l_return_status);


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN
      l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec; --added for nocopy hint
        QP_Qualifier_Rules_Util.Clear_Dependent_Attr
        (   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
        ,   p_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
        ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        );

    END IF;

    --  Default missing attributes



    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN


     oe_debug_pub.add(' executing QP_default_qualifier_rules.attributes ');
     --dbms_output.put_line('calling default qualifier_rule attribute');
            l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec; --added for nocopy hint
        QP_Default_Qualifier_Rules.Attributes
        (   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
        ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        );




    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

     --dbms_output.put_line('calling _rule apply changes attribute');
          l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec; --added for nocopy hint
        QP_Qualifier_Rules_Util.Apply_Attribute_Changes
        (   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
        ,   p_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
        ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Qualifier_Rules.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
            );

        ELSE

           --dbms_output.put_line('entity validation');

            QP_Validate_Qualifier_Rules.Entity
            (   x_return_status               => l_return_status
            ,   p_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
            ,   p_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Qualifier_Rules_Util.Delete_Row
            (   p_qualifier_rule_id           => l_QUALIFIER_RULES_rec.qualifier_rule_id
            );

        ELSE

            --  Get Who Information

            l_QUALIFIER_RULES_rec.last_update_date := SYSDATE;
            l_QUALIFIER_RULES_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_QUALIFIER_RULES_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Qualifier_Rules_Util.Update_Row (l_QUALIFIER_RULES_rec);

            ELSIF l_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_QUALIFIER_RULES_rec.creation_date := SYSDATE;
                l_QUALIFIER_RULES_rec.created_by := FND_GLOBAL.USER_ID;

               --dbms_output.put_line('calling _rule insert row');
               oe_debug_pub.add('calling insert row');
                QP_Qualifier_Rules_Util.Insert_Row (l_QUALIFIER_RULES_rec);

            END IF;

        END IF;

    END IF;

    END IF;  --added for the if added above on 30-nov-99

    --  Load OUT parameters

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_old_QUALIFIER_RULES_rec      := l_old_QUALIFIER_RULES_rec;

    oe_debug_pub.add('leavingqualfiier rule pricate');


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
        x_old_QUALIFIER_RULES_rec      := l_old_QUALIFIER_RULES_rec;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_QUALIFIER_RULES,
		 p_entity_id => l_QUALIFIER_RULES_rec.qualifier_rule_id,
		 x_return_status => l_return_status);
        end if;

        RAISE;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
        x_old_QUALIFIER_RULES_rec      := l_old_QUALIFIER_RULES_rec;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_QUALIFIER_RULES,
		 p_entity_id => l_QUALIFIER_RULES_rec.qualifier_rule_id,
		 x_return_status => l_return_status);
        end if;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifier_Rules'
            );
        END IF;

        l_QUALIFIER_RULES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
        x_old_QUALIFIER_RULES_rec      := l_old_QUALIFIER_RULES_rec;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_QUALIFIER_RULES,
		 p_entity_id => l_QUALIFIER_RULES_rec.qualifier_rule_id,
		 x_return_status => l_return_status);
        end if;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifier_Rules;

--  Qualifierss

PROCEDURE Qualifierss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
,   x_old_QUALIFIERS_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_p_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
    l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;


   --dbms_output.put_line('entering in loop');
   oe_debug_pub.add('entering in qualifierss');
   oe_debug_pub.add('entering in loop with '||l_QUALIFIERS_tbl.COUNT);


    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        --dbms_output.put_line('executing  loop for '||I);



        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

        IF l_old_QUALIFIERS_tbl.EXISTS(I) THEN
            l_old_QUALIFIERS_rec := l_old_QUALIFIERS_tbl(I);
        ELSE
            l_old_QUALIFIERS_rec := QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC;
        END IF;

        --  Load API control record

         oe_debug_pub.add('qualifier rule is = '||l_QUALIFIERS_rec.qualifier_rule_id);
         oe_debug_pub.add('qualifier value is = '||l_QUALIFIERS_rec.qualifier_attr_value);
    oe_debug_pub.add('qualifier value is = '||l_QUALIFIERS_rec.qualifier_attr_value_to);

        --dbms_output.put_line('operation is  '|| l_QUALIFIERS_rec.operation);



        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_QUALIFIERS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_QUALIFIERS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

        --dbms_output.put_line('caliing miss to null');
        oe_debug_pub.add('caliing miss to null');





            l_old_QUALIFIERS_rec :=
            QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

        ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_QUALIFIERS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM
            THEN

                l_old_QUALIFIERS_rec := QP_Qualifiers_Util.Query_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_QUALIFIERS_rec :=
                QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

            END IF;

            --  Complete new record from old
        --dbms_output.put_line('completing record');
        oe_debug_pub.add('completing new reocrd');

            l_QUALIFIERS_rec := QP_Qualifiers_Util.Complete_Record
            (   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

        --dbms_output.put_line('validating record');
        oe_debug_pub.add('validating record by attributes');

                QP_Validate_Qualifiers.Attributes
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

        --dbms_output.put_line('clearing dependent record');

        oe_debug_pub.add('clearing dependent records');

             l_p_QUALIFIERS_rec := l_QUALIFIERS_rec; -- added for nocopy hint
            QP_Qualifiers_Util.Clear_Dependent_Attr
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

        --dbms_output.put_line('defaulting  record');
        oe_debug_pub.add('defaulting  record');


             l_p_QUALIFIERS_rec := l_QUALIFIERS_rec; -- added for nocopy hint
            QP_Default_Qualifiers.Attributes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

        --dbms_output.put_line('applying change attribute  ');
        oe_debug_pub.add('applying change attribute  ');


             l_p_QUALIFIERS_rec := l_QUALIFIERS_rec; -- added for nocopy hint
            QP_Qualifiers_Util.Apply_Attribute_Changes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

             oe_debug_pub.add('checking entity validation condition  ');
             oe_debug_pub.add('operation is '|| l_QUALIFIERS_rec.operation);
            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Qualifiers.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                );

            ELSE

             --dbms_output.put_line('qualifiers entity validation  ');
             oe_debug_pub.add('qualifiers entity validation  ');
                QP_Validate_Qualifiers.Entity
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
                );

             --dbms_output.put_line('qualifiers entity validation  status '||l_return_status);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

		--  Step 3.5. Perform action which need to be performed before
		--            writing to the DB (like Scheduling).
		--added by spgopal for list_qual_ind delayed req

			IF l_control_rec.write_to_db THEN
                           l_p_QUALIFIERS_rec := l_QUALIFIERS_rec; -- added for nocopy hint
				QP_QUALIFIERS_UTIL.PRE_WRITE_PROCESS
				( p_QUALIFIERS_rec      => l_p_QUALIFIERS_rec
				, p_old_QUALIFIERS_rec  => l_old_QUALIFIERS_rec
				, x_QUALIFIERS_rec      => l_QUALIFIERS_rec);

			END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Qualifiers_Util.Delete_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );

            ELSE

                --  Get Who Information

                l_QUALIFIERS_rec.last_update_date := SYSDATE;
                l_QUALIFIERS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_QUALIFIERS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Qualifiers_Util.Update_Row (l_QUALIFIERS_rec);

                ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_QUALIFIERS_rec.creation_date := SYSDATE;
                    l_QUALIFIERS_rec.created_by    := FND_GLOBAL.USER_ID;


                    --dbms_output.put_line('claiing insert');
                    oe_debug_pub.add('calling  insert for qualifiers');

                    QP_Qualifiers_Util.Insert_Row (l_QUALIFIERS_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
        l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

          -- mkarya If process_qualifier_rules has been called from public package, then ONLY
          -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
          if l_control_rec.called_from_ui = 'N' then
            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_header_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_line_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.qualifier_id,
		     x_return_status => l_return_status);
          end if;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

          -- mkarya If process_qualifier_rules has been called from public package, then ONLY
          -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
          if l_control_rec.called_from_ui = 'N' then
            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_header_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_line_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.qualifier_id,
		     x_return_status => l_return_status);
          end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Qualifierss'
                );
            END IF;

          -- mkarya If process_qualifier_rules has been called from public package, then ONLY
          -- call qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
          if l_control_rec.called_from_ui = 'N' then
            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_header_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.list_line_id,
		     x_return_status => l_return_status);

            qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		     p_entity_id => l_QUALIFIERS_rec.qualifier_id,
		     x_return_status => l_return_status);
          end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_old_QUALIFIERS_tbl           := l_old_QUALIFIERS_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifierss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifierss;

--  Start of Comments
--  API name     Process_Qualifier_Rules
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   p_old_QUALIFIERS_tbl            IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Qualifier_Rules';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
l_p_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_QUALIFIER_RULES_rec;
l_old_QUALIFIER_RULES_rec     QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_old_QUALIFIER_RULES_rec;
l_p_old_QUALIFIER_RULES_rec     QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type := p_old_QUALIFIER_RULES_rec;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_old_QUALIFIERS_tbl          QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

-- Blanket Agreement
l_list_header_id              NUMBER;
qual_count                    NUMBER;
l_list_name                   VARCHAR2(240);
BEGIN

    oe_debug_pub.add('entering process qualifier rules');


    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Init local table variables.

    l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
    l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;

    --  Qualifier_Rules

    oe_debug_pub.add('calling qualifier rules');

    l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec;  -- added for nocopy hint
    l_p_old_QUALIFIER_RULES_rec := l_old_QUALIFIER_RULES_rec;
    Qualifier_Rules
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
    ,   p_old_QUALIFIER_RULES_rec     => l_p_old_QUALIFIER_RULES_rec
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_old_QUALIFIER_RULES_rec     => l_old_QUALIFIER_RULES_rec
    );


    oe_debug_pub.add('leaving qualifier rules ' ||x_QUALIFIER_RULES_rec.qualifier_rule_id);



    --  Perform QUALIFIER_RULES group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_QUALIFIER_RULES)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

        oe_debug_pub.add('qualifier rec is ');
        oe_debug_pub.add('id is  ' || l_QUALIFIERS_rec.qualifier_id);
        oe_debug_pub.add('context is  ' || l_QUALIFIERS_rec.qualifier_context);
        oe_debug_pub.add(' attr is  ' || l_QUALIFIERS_rec.qualifier_attribute);
        oe_debug_pub.add(' val  is  ' || l_QUALIFIERS_rec.qualifier_attr_value);



        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_QUALIFIERS_rec.qualifier_rule_id IS NULL OR
            l_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_QUALIFIERS_tbl(I).qualifier_rule_id := l_QUALIFIER_RULES_rec.qualifier_rule_id;
        END IF;

-- Blanket Agreement

	IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE AND
	   l_QUALIFIERS_rec.qualifier_context = 'ORDER' AND
	   l_QUALIFIERS_rec.qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
	THEN
           qual_count := 1;
           BEGIN
              select list_header_id into l_list_header_id
              from qp_qualifiers
              where qualifier_id = l_QUALIFIERS_rec.qualifier_id;

	     BEGIN
              select count(*) into qual_count
              from qp_qualifiers
              where list_header_id = l_list_header_id
	      and qualifier_context = 'ORDER'
	      and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
              and qualifier_id <> l_QUALIFIERS_rec.qualifier_id;
             EXCEPTION
               WHEN OTHERS THEN NULL;
             END;

             IF qual_count = 0 THEN
               update qp_list_headers_b
               set active_flag = 'N'
               where list_header_id = l_list_header_id
	       and list_source_code = 'BSO';

	       select name into l_list_name
	       from qp_list_headers_tl
	       where list_header_id = l_list_header_id;

--Show message saying the BSO PL/Modifier incativated.
		FND_MESSAGE.SET_NAME('QP', 'QP_BSO_PL_MODIFIER_INACTIVATED');
		FND_MESSAGE.SET_TOKEN('BSO_PL_MOD_NAME',l_list_name);
--		FND_MESSAGE.SHOW;
		oe_msg_pub.Add;

             END IF;

	   EXCEPTION
              WHEN OTHERS THEN NULL;
           END;

        END IF;

    END LOOP;

    --  Qualifierss

    --dbms_output.put_line('calling qualifierssi');
    oe_debug_pub.add('calling qualifierss from process rules pvtt');
     l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;   -- added for nocopy hint
     l_p_old_QUALIFIERS_tbl := l_old_QUALIFIERS_tbl;
    Qualifierss
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_old_QUALIFIERS_tbl          => l_p_old_QUALIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
    );

    --  Perform QUALIFIERS group requests.
		oe_debug_pub.add('before if delayed req for warn_same_qual_group');

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_QUALIFIERS)
    THEN

		oe_debug_pub.add('before delayed req for warn_same_qual_group');

			--code modified by spgopal for bug 1501138
			--warning message to be shown
			--when a < 1 qualifier is created in same group with same
			--context and attribute from a pricelist or modifier
				  QP_DELAYED_REQUESTS_PVT.Process_Request_for_entity
						  (p_entity_code   => QP_GLOBALS.G_ENTITY_QUALIFIERS
								  ,p_delete        => FND_API.G_TRUE
								  ,x_return_status => l_return_status
										    );
			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
        NULL;

    END IF;

		oe_debug_pub.add('after if delayed req for warn_same_qual_group');
		oe_debug_pub.add('before if delayed req for list_qual_ind');
		oe_debug_pub.add('before if delayed req for list_qual_ind'||p_control_rec.process_entity);
    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
    THEN

		oe_debug_pub.add('before delayed req for list_qual_ind');
			--code modified by spgopal for bug 1543456
			--qualification_indicator to be updated for qualifiers
			--created when a qualifierrule is copied in pricelist or modifier
			-- FOR QUALIFICATION_IND
				  QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
						  (
								    x_return_status => l_return_status
										    );
			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;

    END IF;
		oe_debug_pub.add('after if delayed req for list_qual_ind');

    --  Done processing, load OUT parameters.

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;

    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    --  Derive return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_QUALIFIER_RULES_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

        IF l_QUALIFIERS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  oe_debug_pub.add('leaving process qualifier rules');


EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_qualifier_rules has been called from public package, then ONLY
        -- call clear_request
        if p_control_rec.called_from_ui = 'N' then
           qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	oe_debug_pub.add('in exception qualifier_rules_pvt');
END Process_Qualifier_Rules;

--  Start of Comments
--  API name    Lock_Qualifier_Rules
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_QUALIFIERS_tbl                IN  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_TBL
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Qualifier_Rules';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Qualifier_Rules_PVT;

    --  Lock QUALIFIER_RULES

    IF p_QUALIFIER_RULES_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Qualifier_Rules_Util.Lock_Row
        (   p_QUALIFIER_RULES_rec         => p_QUALIFIER_RULES_rec
        ,   x_QUALIFIER_RULES_rec         => x_QUALIFIER_RULES_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP

        IF p_QUALIFIERS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Qualifiers_Util.Lock_Row
            (   p_QUALIFIERS_rec              => p_QUALIFIERS_tbl(I)
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Qualifier_Rules_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Qualifier_Rules_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Qualifier_Rules_PVT;

END Lock_Qualifier_Rules;

--  Start of Comments
--  API name    Get_Qualifier_Rules
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Qualifier_Rules
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_qualifier_rule_id             IN  NUMBER
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Qualifier_Rules';
l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_QUALIFIERS_tbl              QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Get QUALIFIER_RULES ( parent = QUALIFIER_RULES )

    l_QUALIFIER_RULES_rec :=  QP_Qualifier_Rules_Util.Query_Row
    (   p_qualifier_rule_id   => p_qualifier_rule_id
    );

        --  Get QUALIFIERS ( parent = QUALIFIER_RULES )

        l_QUALIFIERS_tbl :=  QP_Qualifiers_Util.Query_Rows
        (   p_qualifier_rule_id     => l_QUALIFIER_RULES_rec.qualifier_rule_id
        );


    --  Load out parameters

    x_QUALIFIER_RULES_rec          := l_QUALIFIER_RULES_rec;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Qualifier_Rules'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Qualifier_Rules;



--  Start of Comments
--  API name    Copy_Qualifier_Rule
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


PROCEDURE    Copy_Qualifier_Rule
    (   p_api_version_number              IN NUMBER
    ,   p_init_msg_list                   IN VARCHAR2 := FND_API.G_FALSE
    ,   p_commit                          IN  VARCHAR2 := FND_API.G_FALSE
    ,   x_return_status                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,   x_msg_count                       OUT NOCOPY /* file.sql.39 change */ NUMBER
    ,   x_msg_data                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    ,   p_qualifier_rule_id               IN NUMBER  := FND_API.G_MISS_NUM
    ,   p_to_qualifier_rule               IN VARCHAR2 :=FND_API.G_MISS_CHAR
    ,   p_to_description                  IN VARCHAR2 := FND_API.G_MISS_CHAR
    ,   x_qualifier_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
    ) IS


l_x_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_Qualifier_rule_id           NUMBER;

l_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_p_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
l_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Copy_Qualifier_Rule';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN


    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

   --Get qualifer rule ,qualifier details for the given qualifier rule id


   QP_Qualifier_Rules_PVT.Get_Qualifier_Rules
     (   p_api_version_number    =>1.0
       ,   p_init_msg_list      => FND_API.G_FALSE
       ,   x_return_status  =>l_return_status
       ,   x_msg_count     =>x_msg_count
       ,   x_msg_data      =>x_msg_data
       ,   p_qualifier_rule_id =>p_qualifier_rule_id
       , x_QUALIFIER_RULES_rec=>l_x_QUALIFIER_RULES_rec
       , x_QUALIFIERS_tbl=>l_x_QUALIFIERS_tbl
      );

   --Prepare new qualifier rule record for inserting ,with passed qualifier rule name and
   --description



     l_QUALIFIER_RULES_rec.operation:=QP_GLOBALS.G_OPR_CREATE;
     l_QUALIFIER_RULES_rec.name:=  p_to_qualifier_rule;
     l_QUALIFIER_RULES_rec.description:= p_to_description;


   --Prepare retrieved qualifier records for inserting with new qualifier rule id as parent


     l_QUALIFIERS_tbl := l_x_QUALIFIERS_tbl;

     FOR i in 1..l_QUALIFIERS_tbl.count loop

        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(i);

        --dbms_output.put_line('id  :' ||l_QUALIFIERS_rec.qualifier_id);
        --dbms_output.put_line('rule id  :' ||l_QUALIFIERS_rec.qualifier_rule_id);
        l_QUALIFIERS_tbl(i).operation := QP_GLOBALS.G_OPR_CREATE;
        l_QUALIFIERS_tbl(i).qualifier_id :=FND_API.G_MISS_NUM;
        l_QUALIFIERS_tbl(i).qualifier_rule_id :=FND_API.G_MISS_NUM;

     END LOOP;

   -- call Process qualifiers for inserting new qualifier rule and qualifiers in QP_QUALIFIERS
     l_p_QUALIFIER_RULES_rec := l_QUALIFIER_RULES_rec; -- added for nocopy hint
     l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_QUALIFIER_RULES_rec         => l_p_QUALIFIER_RULES_rec
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   x_QUALIFIER_RULES_rec         => l_QUALIFIER_RULES_rec
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    );

    --  Load out parameters

    x_qualifier_rule_id := l_QUALIFIER_RULES_rec.qualifier_rule_id;



    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Qualifier_Rule'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Copy_Qualifier_Rule;

-- Blanket Agreement

PROCEDURE Create_Blanket_Qualifier
(   p_list_header_id		IN	NUMBER
,   p_old_list_header_id	IN	NUMBER
,   p_blanket_id		IN	NUMBER
,   p_operation			IN	VARCHAR2
,   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
/* For creating qualifiers */
l_price_list_type_code    QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE;
l_QUALIFIERS_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_QUALIFIERS_val_tbl      QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_QUALIFIERS_rec	  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_QUALIFIER_RULES_rec     QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_QUALIFIER_RULES_val_rec QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;

l_control_rec             QP_GLOBALS.Control_Rec_Type;

l_x_QUALIFIERS_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_x_QUALIFIERS_val_tbl    QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_QUALIFIERS_rec	  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_x_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_x_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
l_return_status		VARCHAR2(1);
l_return_values		VARCHAR2(1) := FND_API.G_FALSE;
l_commit		VARCHAR2(1) := FND_API.G_FALSE;
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(250);
l_qual_count		NUMBER;
l_old_qual_count	NUMBER;

BEGIN

oe_debug_pub.add('begin create_blanket_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

    IF p_list_header_id IS NOT NULL OR
		p_list_header_id <> FND_API.G_MISS_NUM THEN

	if p_operation = QP_GLOBALS.G_OPR_CREATE then

			oe_debug_pub.add('in if create : '||p_operation);

		   	l_qualifiers_rec.list_header_id        := p_list_header_id;
		   	l_qualifiers_rec.qualifier_attr_value  := p_blanket_id;
		   	l_qualifiers_rec.qualifier_context     := 'ORDER';
		   	l_qualifiers_rec.qualifier_attribute   := 'QUALIFIER_ATTRIBUTE5';
	   		l_qualifiers_rec.qualifier_grouping_no := p_blanket_id;

		   	l_qualifiers_rec.operation := QP_GLOBALS.G_OPR_CREATE;
		   	l_qualifiers_tbl(1) := l_qualifiers_rec;

			l_control_rec.called_from_ui := 'Y';

		 	QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
		   	(           p_api_version_number	=> 1.0
		   		,   p_init_msg_list	        => FND_API.G_TRUE
				,   p_validation_level          => FND_API.G_VALID_LEVEL_FULL
				,   p_commit	                => FND_API.G_FALSE
				,   x_return_status	        => l_return_status
				,   x_msg_count 	        => l_msg_count
				,   x_msg_data	                => l_msg_data
				,   p_control_rec               => l_control_rec
				,   p_QUALIFIER_RULES_rec       => l_QUALIFIER_RULES_rec
				,   p_QUALIFIERS_tbl            => l_QUALIFIERS_tbl
				,   x_QUALIFIER_RULES_rec       => l_x_QUALIFIER_RULES_rec
				,   x_QUALIFIERS_tbl            => l_x_QUALIFIERS_tbl
			);

	elsif p_operation = OE_GLOBALS.G_OPR_UPDATE then
			oe_debug_pub.add('in if update : '||p_operation);

		if p_old_list_header_id <> p_list_header_id then
			oe_debug_pub.add('in else id!=id'||p_operation);
				delete from qp_qualifiers where
				list_header_id = p_old_list_header_id
				and qualifier_context = 'ORDER'
				and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
				and qualifier_attr_value = p_blanket_id;

		else
			null;
		end if;

		oe_debug_pub.add('in if id=id'||p_operation);

		BEGIN
			select count(list_header_id) into l_qual_count
			from qp_qualifiers where
			list_header_id = p_list_header_id
			and qualifier_context = 'ORDER'
			and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
			and qualifier_attr_value = p_blanket_id;

		EXCEPTION
		When NO_DATA_FOUND Then
		l_qual_count := 0;

		END;

		if l_qual_count < 1 then
			oe_debug_pub.add('in if count'||to_char(l_qual_count));
			l_qualifiers_rec.list_header_id        := p_list_header_id;
		   	l_qualifiers_rec.qualifier_attr_value  := p_blanket_id;
		   	l_qualifiers_rec.qualifier_context     := 'ORDER';
		   	l_qualifiers_rec.qualifier_attribute   := 'QUALIFIER_ATTRIBUTE5';
	   		l_qualifiers_rec.qualifier_grouping_no := p_blanket_id;

		   	l_qualifiers_rec.operation  := QP_GLOBALS.G_OPR_CREATE;
		   	l_qualifiers_tbl(1)         := l_qualifiers_rec;

		else
			oe_debug_pub.add('in else count'||to_char(l_qual_count));
			null;

		end if; --l_qual_count<1

                        l_control_rec.called_from_ui := 'Y';

                        QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
                        (           p_api_version_number	=>   1.0
                                ,   p_init_msg_list             => FND_API.G_TRUE
                                ,   p_validation_level		=> FND_API.G_VALID_LEVEL_FULL
                                ,   p_commit                    => FND_API.G_FALSE
                                ,   x_return_status             => x_return_status
                                ,   x_msg_count                 => l_msg_count
                                ,   x_msg_data                  => l_msg_data
                                ,   p_control_rec               => l_control_rec
                                ,   p_QUALIFIER_RULES_rec	=> l_QUALIFIER_RULES_rec
                                ,   p_QUALIFIERS_tbl            => l_QUALIFIERS_tbl
                                ,   x_QUALIFIER_RULES_rec	=> l_x_QUALIFIER_RULES_rec
                                ,   x_QUALIFIERS_tbl            => l_x_QUALIFIERS_tbl
                        );

	elsif p_operation = OE_GLOBALS.G_OPR_DELETE then
		oe_debug_pub.add('in if delete : '||p_operation);

		if p_old_list_header_id <> p_list_header_id then
			oe_debug_pub.add('in else id != id '||p_operation);
				delete from qp_qualifiers where
				list_header_id = p_old_list_header_id
				and qualifier_context = 'ORDER'
				and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
				and qualifier_attr_value = p_blanket_id;

		else
			null;
		end if;

		BEGIN
			oe_debug_pub.add('in if id=id'||p_operation);
			delete from qp_qualifiers where
			list_header_id = p_old_list_header_id
			and qualifier_context = 'ORDER'
			and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
			and qualifier_attr_value = p_blanket_id;
		EXCEPTION
		When NO_DATA_FOUND Then
		l_qual_count := 0;

		END;
	end if; --operation
    END IF;

    oe_debug_pub.add('end create_blanket_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

EXCEPTION

    WHEN OTHERS THEN
                  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                       OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME
                       ,   'Create_Blanket_Qualifier'
                       );
		  END IF;

                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  --  Get message count and data
                      OE_MSG_PUB.Count_And_Get
                       (   p_count     => l_msg_count
                       ,   p_data      => l_msg_data
                       );

    oe_debug_pub.add('exp create_blanket_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

END Create_Blanket_Qualifier;

END QP_Qualifier_Rules_PVT;

/
