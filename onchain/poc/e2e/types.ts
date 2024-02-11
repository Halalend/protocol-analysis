import { Data } from "https://deno.land/x/lucid@0.10.7/mod.ts";

const MyDatumSchema = Data.Object({
  owner: Data.Bytes(),
  target: Data.Integer(),
});

// Redeemer Schema
const RedeemerSchema = Data.Enum([
  Data.Object({
    Unlock: Data.Object({
      pool_references: Data.Array(Data.Object({
        output_ref: Data.Object({
          transaction_id: Data.Object({
            hash: Data.Bytes(),
          }),
          output_index: Data.Integer(),
        }),
        pool_type: Data.Integer(),
      })),
    }),
  }),
  Data.Literal("Cancel"),
]);

type MyRedeemer = Data.Static<typeof RedeemerSchema>;
const MyRedeemer = RedeemerSchema as unknown as MyRedeemer;

type MyDatum = Data.Static<typeof MyDatumSchema>;
const MyDatum = MyDatumSchema as unknown as MyDatum;

export { MyDatum, MyRedeemer };
