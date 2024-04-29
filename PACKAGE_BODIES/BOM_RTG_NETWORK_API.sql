--------------------------------------------------------
--  DDL for Package Body BOM_RTG_NETWORK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_NETWORK_API" AS
/* $Header: BOMRNWKB.pls 120.2 2006/02/02 23:07:16 abbhardw ship $ */

FUNCTION get_routing_sequence_id (
	p_assy_item_id      IN  NUMBER,
	p_org_id            IN  NUMBER,
	p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

l_rtg_seq_id NUMBER := NULL;

BEGIN
	select routing_sequence_id
	into   l_rtg_seq_id
	from   bom_operational_routings
	where  assembly_item_id = p_assy_item_id
	and    organization_id  = p_org_id
	and    NVL(alternate_routing_designator, 'NONE') =
				NVL(p_alt_rtg_desig, 'NONE');

	return (l_rtg_seq_id);

EXCEPTION WHEN NO_DATA_FOUND THEN
	return null;
END;

FUNCTION find_line_op (
				p_line_op IN NUMBER,
				p_op_tbl  IN Op_Tbl_Type) RETURN BOOLEAN IS
i INTEGER;
BEGIN
	FOR i IN 1..p_op_tbl.COUNT LOOP
		if p_op_tbl(i).operation_seq_num = p_line_op then
		return (TRUE);
		end if;
	END LOOP;
	return (FALSE);
END find_line_op;

FUNCTION check_network_exists (
				p_rtg_sequence_id IN NUMBER) RETURN BOOLEAN IS
net_exists NUMBER;
BEGIN
	select 1
	into   net_exists
	from dual
	where exists (select null
			from bom_operation_networks_v
			where routing_sequence_id = p_rtg_sequence_id
			and   operation_type = 3);

	return (TRUE);
EXCEPTION WHEN NO_DATA_FOUND THEN
	return(FALSE);
END check_network_exists;

PROCEDURE get_all_prior_line_ops (
	p_rtg_sequence_id 	IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER,
    x_Op_Tbl      		 IN OUT NOCOPY  Op_Tbl_Type ) IS
i INTEGER := 1;
l_rtg_seq_id NUMBER;
l_op_seq_id NUMBER;
l_op_seq_num NUMBER;
cursor all_prior_line_ops (c_line_op_id NUMBER) IS
    select  from_op_seq_id operation_sequence_id
    from bom_operation_networks
    connect by prior from_op_seq_id = to_op_seq_id
        and transition_type <> 3
    start with to_op_seq_id = c_line_op_id
        and transition_type <> 3;
cursor all_prior_line_ops2 IS
	select operation_sequence_id, operation_seq_num
	from   bom_operation_sequences
	where  routing_sequence_id = l_rtg_seq_id
	and    operation_seq_num < p_curr_line_op
	and    operation_type = 3
	and    nvl(eco_for_production,2) = 2
	and exists (select null
		from bom_operation_sequences
		where routing_sequence_id = l_rtg_seq_id
		and  operation_seq_num = p_curr_line_op
	        and    nvl(eco_for_production,2) = 2
		and  operation_type = 3);
BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
                        p_assy_item_id,
                        p_org_id,
                        p_alt_rtg_desig);
	end if;


	if  check_network_exists(l_rtg_seq_id)  then
		select operation_sequence_id
		into   l_op_seq_id
		from   bom_operation_sequences
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_type = 3
	        and    nvl(eco_for_production,2) = 2
		and    operation_seq_num = p_curr_line_op;

        FOR all_prior_line_op_rec IN all_prior_line_ops(l_op_seq_id) LOOP
			select operation_seq_num
			into   l_op_seq_num
			from   bom_operation_sequences
			where  operation_sequence_id =
					all_prior_line_op_rec.operation_sequence_id;

			if (NOT find_line_op (l_op_seq_num, x_Op_Tbl)) then
				x_Op_Tbl(i).operation_sequence_id :=
					all_prior_line_op_rec.operation_sequence_id;
				x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
				i := i + 1;
			end if;
        END LOOP;
	else
		FOR all_prior_line_op_rec2 IN all_prior_line_ops2 LOOP
			x_Op_Tbl(i).operation_sequence_id :=
				all_prior_line_op_rec2.operation_sequence_id;
			x_Op_Tbl(i).operation_seq_num :=
				all_prior_line_op_rec2.operation_seq_num;
			i := i + 1;
		END LOOP;
	end if;
EXCEPTION WHEN NO_DATA_FOUND THEN
	NULL;
END get_all_prior_line_ops;


PROCEDURE get_primary_prior_line_ops (
	p_rtg_sequence_id   IN NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER,
    x_Op_Tbl            IN OUT NOCOPY Op_Tbl_Type ) IS

i INTEGER := 1;
l_rtg_seq_id NUMBER;
l_transition_type NUMBER := 2;
l_last_alt_line_op NUMBER;
l_op_seq_num NUMBER;
l_op_seq_id  NUMBER;
cursor primary_prior_line_ops (c_line_op_id NUMBER) IS
    select  from_op_seq_id operation_sequence_id
    from bom_operation_networks
    connect by prior from_op_seq_id = to_op_seq_id
		and transition_type NOT IN (2, 3)
    start with to_op_seq_id = c_line_op_id
		and transition_type NOT IN (2, 3);

cursor alt_prior_line_ops (c_line_op_id NUMBER) IS
    select  from_op_seq_id operation_sequence_id
    from bom_operation_networks
    connect by prior from_op_seq_id = to_op_seq_id
				and  transition_type NOT IN (1, 3)
    start with to_op_seq_id = c_line_op_id
				and  transition_type NOT IN (1, 3);

cursor primary_prior_line_ops2 IS
    select operation_sequence_id, operation_seq_num
    from   bom_operation_sequences
    where  routing_sequence_id = l_rtg_seq_id
    and    operation_seq_num < p_curr_line_op
    and    operation_type = 3
    and    nvl(eco_for_production,2) = 2
	and exists (select null
		from bom_operation_sequences
		where routing_sequence_id = l_rtg_seq_id
		and   operation_seq_num = p_curr_line_op
                and    nvl(eco_for_production,2) = 2
		and   operation_type = 3);

BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
						p_assy_item_id,
						p_org_id,
						p_alt_rtg_desig);
	end if;

	if check_network_exists(l_rtg_seq_id) then
	BEGIN
		select operation_sequence_id
		into   l_op_seq_id
		from   bom_operation_sequences
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_type = 3
		and    operation_seq_num = p_curr_line_op;

		select 1
		into   l_transition_type
		from   bom_operation_networks
		where  to_op_seq_id = l_op_seq_id
		and    transition_type = 1
		and    rownum =1 ;

		FOR primary_line_op_rec IN primary_prior_line_ops(l_op_seq_id) LOOP
		select operation_seq_num
		into   l_op_seq_num
		from   bom_operation_sequences
		where  operation_sequence_id =
				primary_line_op_rec.operation_sequence_id;
		If (NOT find_line_op(l_op_seq_num, x_Op_Tbl)) then
        x_Op_Tbl(i).operation_sequence_id :=
			primary_line_op_rec.operation_sequence_id;
		x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
        i := i + 1;
		end if;
		END LOOP;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		FOR alt_line_op_rec IN alt_prior_line_ops(l_op_seq_id) LOOP
			select operation_seq_num
			into   l_op_seq_num
			from   bom_operation_sequences
			where  operation_sequence_id =
					alt_line_op_rec.operation_sequence_id;

			if (NOT find_line_op(l_op_seq_num, x_Op_Tbl)) then
			x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
			x_Op_Tbl(i).operation_sequence_id :=
				alt_line_op_rec.operation_sequence_id;
			i := i + 1;
			end if;
			l_last_alt_line_op := alt_line_op_rec.operation_sequence_id;
		END LOOP;
		FOR primary_line_op_rec IN
				primary_prior_line_ops(l_last_alt_line_op)
		 LOOP
			select operation_seq_num
			into   l_op_seq_num
			from   bom_operation_sequences
			where  operation_sequence_id =
					primary_line_op_rec.operation_sequence_id;
			 if (NOT find_line_op(l_op_seq_num, x_Op_Tbl)) then
				x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
				x_Op_Tbl(i).operation_sequence_id :=
					primary_line_op_rec.operation_sequence_id;
				i := i + 1;
			end if;
        END LOOP;
	END;
	else
	BEGIN
	 	FOR primary_prior_line_ops2_rec IN primary_prior_line_ops2 LOOP
			x_Op_Tbl(i).operation_seq_num :=
				primary_prior_line_ops2_rec.operation_seq_num;
			x_Op_Tbl(i).operation_sequence_id :=
				primary_prior_line_ops2_rec.operation_sequence_id;
			i := i + 1;
		END LOOP;
	END;
	end if;
EXCEPTION WHEN NO_DATA_FOUND THEN
	NULL;
END get_primary_prior_line_ops;

PROCEDURE get_all_line_ops (
	p_rtg_sequence_id	IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL,
    x_Op_Tbl     		 IN OUT NOCOPY  Op_Tbl_Type ) IS

l_rtg_seq_id NUMBER := NULL;
I Integer := 1;
/*Cursor all_line_ops  is
	select from_seq_num operation_seq_num ,
		   from_op_seq_id operation_sequence_id
	from bom_operation_networks_v
	where routing_sequence_id = l_rtg_seq_id
	and   operation_type = 3
	and   transition_type <> 3
	union
	select bonv.to_seq_num operation_seq_num,
		   to_op_seq_id operation_sequence_id
	from bom_operation_networks_v bonv
	where routing_sequence_id = l_rtg_seq_id
	and   operation_type = 3
	and not exists (select null
		from bom_operation_networks_v net
		where bonv.to_op_seq_id = net.from_op_seq_id
		and   transition_type <> 3
		and net.routing_sequence_id = l_rtg_seq_id);
*/
-- Replaced the sql for the cursor above with the one below for better performance BUG 4929600
Cursor all_line_ops  is
	select  bos1.operation_seq_num operation_seq_num ,
                bon1.from_op_seq_id operation_sequence_id
	from bom_operation_networks bon1 ,bom_operation_sequences bos1
	where bos1.routing_sequence_id = l_rtg_seq_id
		and bos1.operation_type = 3
		and bon1.transition_type <> 3
		and bon1.from_op_seq_id = bos1.operation_sequence_id
	union
	select bos2.operation_seq_num operation_seq_num,
		bon2.to_op_seq_id operation_sequence_id
	from bom_operation_networks bon2, bom_operation_sequences bos2
	where bos2.routing_sequence_id = l_rtg_seq_id
		and bos2.operation_type = 3
		and bon2.to_op_seq_id = bos2.operation_sequence_id
	and not exists ( select null
		from bom_operation_networks net ,bom_operation_sequences bos3
		where bon2.to_op_seq_id = net.from_op_seq_id
		     and net.transition_type <> 3
		     and bos3.routing_sequence_id = l_rtg_seq_id
		     and net.from_op_seq_id = bos3.operation_sequence_id );
cursor all_line_ops2 IS
    select operation_sequence_id, operation_seq_num
    from   bom_operation_sequences
    where  routing_sequence_id = l_rtg_seq_id
    and    nvl(eco_for_production,2) = 2
    and    operation_type = 3;

BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
						p_assy_item_id,
						p_org_id,
						p_alt_rtg_desig);
	end if;

	if check_network_exists(l_rtg_seq_id) then
		FOR line_op_rec IN all_line_ops LOOP
			x_Op_Tbl(I).operation_seq_num := line_op_rec.operation_seq_num;
			x_Op_Tbl(I).operation_sequence_id :=
				line_op_rec.operation_sequence_id;
			I := I + 1;
		END LOOP;
	else
		FOR all_line_ops2_rec IN all_line_ops2 LOOP
			x_Op_Tbl(I).operation_seq_num :=
				all_line_ops2_rec.operation_seq_num;
			x_Op_Tbl(I).operation_sequence_id :=
				all_line_ops2_rec.operation_sequence_id;
			i := i + 1;
		END LOOP;
	end if;
END get_all_line_ops;

PROCEDURE get_all_primary_line_ops (
	p_rtg_sequence_id	IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    x_Op_Tbl     		 IN OUT NOCOPY  Op_Tbl_Type ) IS

l_rtg_seq_id NUMBER := NULL;
I Integer := 1;
/*Cursor all_primary_line_ops  is
    select from_seq_num operation_seq_num ,
           from_op_seq_id operation_sequence_id
    from bom_operation_networks_v
    where routing_sequence_id = l_rtg_seq_id
	and   transition_type = 1
    and   operation_type = 3
    union
    select bonv.to_seq_num operation_seq_num,
           to_op_seq_id operation_sequence_id
    from bom_operation_networks_v bonv
    where routing_sequence_id = l_rtg_seq_id
	and   transition_type = 1
    and   operation_type = 3
    and not exists (select null
        from bom_operation_networks_v net
        where bonv.to_op_seq_id = net.from_op_seq_id
		and transition_type <> 3
        and net.routing_sequence_id = l_rtg_seq_id);
*/
-- Replaced the sql for the cursor above with the one below for better performance BUG 4929600
Cursor all_primary_line_ops is
    select bos1.operation_seq_num operation_seq_num ,
           bon1.from_op_seq_id operation_sequence_id
    from bom_operation_networks bon1 ,bom_operation_sequences bos1
    where bos1.routing_sequence_id = l_rtg_seq_id
	   and bon1.transition_type = 1
	   and bos1.operation_type = 3
	   and bon1.from_op_seq_id = bos1.operation_sequence_id
    union
    select bos2.operation_seq_num operation_seq_num,
           bon2.to_op_seq_id operation_sequence_id
    from bom_operation_networks bon2, bom_operation_sequences bos2
    where bos2.routing_sequence_id = l_rtg_seq_id
	   and bon2.transition_type = 1
	   and bos2.operation_type = 3
	   and bon2.to_op_seq_id = bos2.operation_sequence_id
    and not exists ( select null
           from bom_operation_networks net ,bom_operation_sequences bos3
           where bon2.to_op_seq_id = net.from_op_seq_id
		and net.transition_type <> 3
		and bos3.routing_sequence_id = l_rtg_seq_id
		and net.from_op_seq_id = bos3.operation_sequence_id );

cursor all_primary_line_ops2 IS
    select operation_sequence_id, operation_seq_num
    from   bom_operation_sequences
    where  routing_sequence_id = l_rtg_seq_id
    and    nvl(eco_for_production,2) = 2
    and    operation_type = 3;

BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
                        p_assy_item_id,
                        p_org_id,
                        p_alt_rtg_desig);
 	end if;
	if check_network_exists(l_rtg_seq_id) then
		FOR line_op_rec IN all_primary_line_ops LOOP
			x_Op_Tbl(I).operation_seq_num := line_op_rec.operation_seq_num;
			x_Op_Tbl(I).operation_sequence_id :=
				line_op_rec.operation_sequence_id;
			I := I + 1;
		END LOOP;
	else
		FOR all_primary_line_ops2_rec IN all_primary_line_ops2 LOOP
			x_Op_Tbl(I).operation_seq_num :=
				all_primary_line_ops2_rec.operation_seq_num;
			x_Op_Tbl(I).operation_sequence_id :=
				all_primary_line_ops2_rec.operation_sequence_id;
			I := I + 1;
		END LOOP;
	end if;

END get_all_primary_line_ops;

PROCEDURE get_all_next_line_ops (
	p_rtg_sequence_id	IN 	NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER,
    x_Op_Tbl      		 IN OUT NOCOPY  Op_Tbl_Type ) IS
i INTEGER := 1;
l_rtg_seq_id NUMBER;
l_op_seq_id NUMBER;
l_op_seq_num NUMBER;
cursor all_next_line_ops (c_line_op_id NUMBER) IS
    select  to_op_seq_id operation_sequence_id
    from bom_operation_networks
    connect by prior to_op_seq_id = from_op_seq_id
        and transition_type <> 3
    start with from_op_seq_id = c_line_op_id
        and transition_type <> 3;
cursor all_next_line_ops2 IS
    select operation_sequence_id, operation_seq_num
    from   bom_operation_sequences
    where  routing_sequence_id = l_rtg_seq_id
	and    operation_seq_num > p_curr_line_op
    and    nvl(eco_for_production,2) = 2
    and    operation_type = 3
	and exists (select null
		from   bom_operation_sequences
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_seq_num = p_curr_line_op
		and    operation_type = 3);

BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
                        p_assy_item_id,
                        p_org_id,
                        p_alt_rtg_desig);
	end if;

	if check_network_exists(l_rtg_seq_id) then
		select operation_sequence_id
		into   l_op_seq_id
		from   bom_operation_sequences
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_type = 3
		and    operation_seq_num = p_curr_line_op;

        FOR all_next_line_op_rec IN all_next_line_ops(l_op_seq_id) LOOP
			select operation_seq_num
			into   l_op_seq_num
			from   bom_operation_sequences
			where  operation_sequence_id =
					all_next_line_op_rec.operation_sequence_id;
			if (NOT find_line_op (l_op_seq_num, x_Op_Tbl)) then
				x_Op_Tbl(i).operation_sequence_id :=
					all_next_line_op_rec.operation_sequence_id;
				x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
				i := i + 1;
			end if;
        END LOOP;
	else
		FOR all_next_line_ops2_rec IN all_next_line_ops2 LOOP
			x_Op_Tbl(i).operation_sequence_id :=
				all_next_line_ops2_rec.operation_sequence_id;
			 x_Op_Tbl(i).operation_seq_num :=
				all_next_line_ops2_rec.operation_seq_num;
			i := i + 1;
		END LOOP;
	end if;
EXCEPTION WHEN NO_DATA_FOUND THEN
	null;
END get_all_next_line_ops;

FUNCTION get_next_line_operation (
	p_rtg_sequence_id 	IN 	NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER ) RETURN NUMBER IS

l_rtg_seq_id NUMBER;
next_line_op NUMBER := NULL;
BEGIN
	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
						p_assy_item_id,
						p_org_id,
						p_alt_rtg_desig );
	end if;

	if check_network_exists(l_rtg_seq_id) then
	BEGIN
		select to_seq_num
		into   next_line_op
		from   bom_operation_networks_v
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_type = 3
		and    from_seq_num = p_curr_line_op
		and    transition_type = 1;

		return (next_line_op);

	EXCEPTION WHEN NO_DATA_FOUND THEN
		BEGIN
			select min(to_seq_num)
			into   next_line_op
			from   bom_operation_networks_v
			where  routing_sequence_id = l_rtg_seq_id
			and    operation_type = 3
			and    from_seq_num = p_curr_line_op
			and    transition_type = 2;

			return (next_line_op);

		EXCEPTION WHEN NO_DATA_FOUND THEN
			return (NULL);
		END;
	END;
	else
	BEGIN
		select MIN(operation_seq_num)
		into   next_line_op
		from   bom_operation_sequences
		where  routing_sequence_id = l_rtg_seq_id
		and    operation_type = 3
                and    nvl(eco_for_production,2) = 2
		and    operation_seq_num > p_curr_line_op
		and    exists (select null
					from bom_operation_sequences
					where routing_sequence_id = l_rtg_seq_id
					and   operation_type = 3
					and   operation_seq_num = p_curr_line_op);

		return (next_line_op);

	EXCEPTION WHEN NO_DATA_FOUND THEN
		return (NULL);
	END;
	end if;
END get_next_line_operation;

FUNCTION check_last_line_op (
	p_rtg_sequence_id	IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2,
    p_curr_line_op      IN  NUMBER ) RETURN BOOLEAN IS

l_rtg_seq_id NUMBER;
l_last_op NUMBER;

BEGIN

	if p_rtg_sequence_id is not null then
		l_rtg_seq_id := p_rtg_sequence_id;
	else
		l_rtg_seq_id := get_routing_sequence_id (
						p_assy_item_id,
						p_org_id,
						p_alt_rtg_desig );
	end if;

	if check_network_exists (l_rtg_seq_id) then
	BEGIN
		select 1
		into   l_last_op
		from dual
		where not exists (select null
					from  bom_operation_networks_v
					where from_seq_num = p_curr_line_op
					and   operation_type = 3
					and   transition_type <> 3
					and   routing_sequence_id = l_rtg_seq_id)
		and exists (select null
				from   bom_operation_networks_v
				where  to_seq_num = p_curr_line_op
				and   transition_type <> 3
				and    operation_type = 3
				and    routing_sequence_id = l_rtg_seq_id);
		return (TRUE);

	EXCEPTION WHEN NO_DATA_FOUND THEN
		return (FALSE);
	END;
	else
	BEGIN
		select 1
		into   l_last_op
		from dual
		where not exists (select null
				from bom_operation_sequences
				where routing_sequence_id = l_rtg_seq_id
				and   operation_type = 3
                                and    nvl(eco_for_production,2) = 2
				and   operation_seq_num > p_curr_line_op)
			and exists (select null
				from   bom_operation_sequences
				where  routing_sequence_id = l_rtg_seq_id
				and    operation_type = 3
				and    operation_seq_num = p_curr_line_op);

		return (TRUE);
	EXCEPTION WHEN NO_DATA_FOUND THEN
		return (FALSE);
	END;
	end if;

END check_last_line_op;

END BOM_RTG_NETWORK_API;

/
