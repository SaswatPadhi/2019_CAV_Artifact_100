open Core
open LoopInvGen

let time_pseudolog x =
  if x > 3600.0 then 1
  else if x >= 1000.0 then 2
  else if x >= 300.0 then 3
  else if x >= 100.0 then 4
  else if x >= 30.0 then 5
  else if x >= 10.0 then 6
  else if x >= 3.0 then 7
  else if x >= 1.0 then 8
  else 9

let size_pseudolog x =
  if x > 1000 then 1
  else if x >= 300 then 2
  else if x >= 100 then 3
  else if x >= 30 then 4
  else if x >= 10 then 5
  else 6

let rec count_nodes = let open Sexplib.Sexp in function
  | Atom _ -> 1
  | List l -> List.fold l ~init:0 ~f:(fun acc s -> acc + (count_nodes s))

let main running_time invfile () =
  let time_score = time_pseudolog running_time in
  let open Sexplib.Sexp in
  let size_score = match input_rev_sexps (Utils.get_in_channel invfile) with
    | [] | [ (List [Atom "fail"]) ] -> size_pseudolog 1
    | [ List [ (Atom "define-fun") ; (Atom _) ; (List _) ; (Atom "Bool") ; body ] ]
      -> size_pseudolog (count_nodes body)
    | _ -> raise (Exceptions.Parse_Exn
                    "Bad/multiple S-exprs detected, expecting invariant as a single valid S-expr.")
   in Out_channel.output_string Stdio.stdout
                                ((Int.to_string time_score) ^ "," ^ (Int.to_string size_score))

let spec =
  let open Command.Spec in (
    empty
    +> flag "-t" (required float)
       ~doc:"FLOAT The running time in seconds."
    +> anon (maybe_with_default "-" ("filename" %: file))
  )

let () =
  Command.run
    (Command.basic_spec spec main
       ~summary: "Compute scores for an invariant based on the pseudolog scale for size and time.")
