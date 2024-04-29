--------------------------------------------------------
--  DDL for Package Body INV_COST_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_COST_GROUP_PUB" AS
/* $Header: INVPDCGB.pls 120.1 2005/06/17 17:21:34 appldev  $ */

--  Global constant holding the package name

--G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_COST_GROUP_PUB';
is_debug BOOLEAN := TRUE;

--  Start of Comments
--  API name    Assign_Cost_Group
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  End of Comments

procedure print_debug(p_message in VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
    if( is_debug = TRUE ) then
        --inv_debug.message('ssia', p_message);
        null;
    end if;
end;

procedure set_globals(p_cost_group_id IN NUMBER,
		     p_transfer_cost_group_id IN NUMBER)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    g_cost_group_id := p_cost_group_id;
    g_transfer_cost_group_id := p_transfer_cost_group_id;
END;

procedure get_globals(x_cost_group_id OUT NOCOPY NUMBER,
		     x_transfer_cost_group_id OUT NOCOPY NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    x_cost_group_id := g_cost_group_id;
    x_transfer_cost_group_id := g_transfer_cost_group_id;
END;

PROCEDURE Assign_Cost_Group
(
    p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_input_type                    IN  VARCHAR2
,   x_cost_Group_id                 OUT NOCOPY NUMBER
,   x_transfer_cost_Group_id        OUT NOCOPY NUMBER
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- call the private package
   inv_cost_group_pvt.assign_cost_group(
   	x_return_status                 => x_return_status,
   	x_msg_count                     => x_msg_count,
   	x_msg_data                      => x_msg_data,
   	p_line_id                       => p_line_id,
   	p_organization_id               => p_organization_id,
   	p_input_type                    => p_input_type,
   	x_cost_Group_id                 => x_cost_group_id,
   	x_transfer_cost_Group_id        => x_transfer_cost_group_id);
   if( x_return_status = FND_API.G_RET_STS_ERROR ) then
	raise FND_API.G_EXC_ERROR;
   elsif( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   if( p_commit = FND_API.G_TRUE ) then
	commit;
   end if;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME, 'INV_COST_GROUP_PUB');
        end if;
END Assign_Cost_Group;
END;


/
