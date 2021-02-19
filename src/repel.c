#include "../include/save.h"

typedef BOOL (*ScriptFuction)(void *);
typedef struct Script_Struct ScriptContext;
typedef void (*SpecialFunc)(ScriptContext *ctx);

struct Unkstruct
{
    void *unk_0;
    void *unk_4;
    void *unk_8;
    void *savedata;
};

struct Script_Struct
{
    u8 unk_0;
    u8 unk_1;
    u8 unk_2;
    ScriptFuction unk_3;
    const u8 *scriptPtr;
    void *array[20];
    void *command_table;
    u32 cmd_max;
    u32 reg[4];
    void *unk_4;
    void *unk_5;
    void *pScript;
    struct Unkstruct *fsys;
};

typedef struct
{
    void *unk_0;
    u8 unk_4;
    u8 x;
    u8 y;
    u8 width;
    u8 height;
    u8 palnum;
    u16 unk_A:15;
    u16 unk_B:1;
    void *unk_C;
}WindowsTemplate;

struct BAG_DATA
{
    void *savePtr;
};

typedef struct
{
    void *unk_0;
    WindowsTemplate win[11];
    WindowsTemplate add_win[1];
    struct BAG_DATA *data;
}Bag_Struct;

#define ScriptReadByte(ctx) (*((ctx)->scriptPtr++))
#define SPECIAL_GET_LAST_USED_REPEL 0

static void TryUseRepel(ScriptContext *ctx);
static void GetLastUsedRepel(ScriptContext *ctx);

const SpecialFunc gSpecials[] =
{
    [SPECIAL_GET_LAST_USED_REPEL] = GetLastUsedRepel,
    [3] = TryUseRepel,
};

BOOL ScrCmd_special(ScriptContext *ctx)
{
    u8 index = ScriptReadByte(ctx);

    gSpecials[index](ctx);
    return 0;
}

static void TryUseRepel(ScriptContext *ctx)
{
    u8 *repel_saveData = SaveData_GetRepelPtr(GetSaveDataPtr(ctx->fsys->savedata));
    struct save_dex_data *dex = SaveData_GetDexPtr(ctx->fsys->savedata);
    u8 step = 0;
    u8 Repel = dex->repel;

    if (Repel == 79)
        step = 100;
    else if (Repel == 76)
        step = 200;
    else if (Repel == 77)
        step = 250;

    *repel_saveData = step;
}

static void GetLastUsedRepel(ScriptContext *ctx)
{
    struct save_dex_data *dex = SaveData_GetDexPtr(ctx->fsys->savedata);
    u16 *offset = GetEventVar(ctx->fsys, 53);

    *offset = dex->repel;
}

void BAG_SaveDataRepelSet(Bag_Struct *Bag_Data, u8 param)
{
    u8 *repel_saveData;
    struct save_dex_data *dex = SaveData_GetDexPtr(Bag_Data->data->savePtr);

    if (param == 100)
        dex->repel = 79;
    else if (param == 200)
        dex->repel = 76;
    else if (param == 250)
        dex->repel = 77;

    repel_saveData = SaveData_GetRepelPtr(GetSaveDataPtr(Bag_Data->data->savePtr));
    *repel_saveData = param;
}