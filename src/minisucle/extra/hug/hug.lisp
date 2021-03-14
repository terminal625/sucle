;;;; hug.lisp

(in-package #:hug)

(defun setup ()
  #+nil
  (py4cl2:pyexec
   "
import torch
from transformers import BertTokenizer, BertModel,BertForMaskedLM
tokenizer = BertTokenizer.from_pretrained('bert-base-cased')
model = BertForMaskedLM.from_pretrained('bert-base-cased')   
"
   )
#+nil
  (py4cl2:pyexec
   "
import torch
from transformers import BertTokenizer, BertModel,BertForMaskedLM
tokenizer = BertTokenizer.from_pretrained('bert-large-cased-whole-word-masking')
model = BertForMaskedLM.from_pretrained('bert-large-cased-whole-word-masking')
"
   )
;;#+nil
  (py4cl2:pyexec
   "
import torch
from transformers import BertTokenizer, BertModel,BertForMaskedLM
tokenizer = BertTokenizer.from_pretrained('bert-large-uncased')
model = BertForMaskedLM.from_pretrained('bert-large-uncased')
"
   ))

(defun mask-id ()
  (py4cl2:pyexec
   "
inputs = tokenizer(\"[CLS][SEP][MASK]\", return_tensors='pt')
# print(inputs)
len = inputs.input_ids
# print([len[0][1], len[0][2], len[0][3]])"
   )
  (let ((array (py4cl2:pyeval "[len[0][1].item(), len[0][2].item(), len[0][3].item()]")))
    (list :cls (aref array 0)
	  :sep (aref array 1)
	  :mask (aref array 2)))
  )

(defparameter *teststr* "[MASK] [MASK] [MASK] of the United States mismanagement of the Coronavirus is its distrust of science.")
(defun results
    (&optional (str *teststr*))
  (setf (py4cl2:pyeval "input_txt")
	(py4cl2:pythonize str))
  (setf (py4cl2:pyeval "top") 10)
  (py4cl2:pyexec
   "
inputs = tokenizer(input_txt, return_tensors='pt')
# print(inputs)
# 
len = list(inputs.input_ids.size())[1]
# print(len)
outputs = model(**inputs)
predictions = outputs[0]
sorted_preds, sorted_idx = predictions[0].sort(dim=-1, descending=True)
# print(sorted_idx.size())

inputids = inputs.input_ids[0].tolist()
acc = [[tokenizer.convert_ids_to_tokens(inputids), inputids]]
for k in range(top):
   predicted_index = [sorted_idx[i, k].item() for i in range(0,len)]
   predicted_token = tokenizer.convert_ids_to_tokens(predicted_index)
   acc.append([predicted_token,predicted_index])"
   )

  (py4cl2:pyeval "acc"))

;;https://stackoverflow.com/questions/46826218/pytorch-how-to-get-the-shape-of-a-tensor-as-a-list-of-int
(defun safe-subseq (str start end)
  (subseq str (max 0 start)
	  (min end (length str))))
(defun foo (&optional (str *teststr*))
  (let ((res (results str))
	(first t))
    (loop :for seq :across res :collect
       (with-output-to-string (stream)
	 (loop :for str :across seq :do
	    (progn	   
	      (cond ((string=
		      (safe-subseq str 0 2)
		      "##")
		     (setf str (safe-subseq str 2 (length str)))
		     (write-char #\| stream))
		    ((not first)
		     (write-char #\Space stream)))
	      (write-string str stream)
	      (when first
		(setf first nil))))))))

"Websites: Thousands of \"mirror sites\" exist that republish content from Wikipedia: two prominent ones, that also include content from other reference sources, are Reference.com and Answers.com. Another example is Wapedia, which began to display Wikipedia content in a mobile-device-friendly format before Wikipedia itself did."
(defparameter *teststrs*
  '("[MASK] [MASK] [MASK] of the United States mismanagement of the Coronavirus is its distrust of science."
    ;;"grass, [MASK], frog, [MASK], dog, [MASK], cat, [MASK], seed, [MASK], tree, [MASK], computer, [MASK], fire hydrant, [MASK], sidewalk, [MASK], ladybug, [MASK], octopus, [MASK], mask, [MASK],"
    "[MASK],[MASK],[MASK],[MASK],[MASK],[MASK],"
    "The sun, mars, earth and [MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK][MASK]"
    ;;"[CLS] The earth revolves around the [MASK]."
    ;;"[MASK] [MASK] [MASK] of the United States mismanagement of the Coronavirus is its distrust of science."
    "Websites: Thousands of \"mirror sites\" exist [MASK] republish content from Wikipedia: two prominent ones, that also include content [MASK] [MASK], are Reference.com and Answers.com. [MASK] [MASK] [MASK] [MASK], which began to display Wikipedia content in a mobile-device-friendly format before Wikipedia itself did."))
(defun test ()
  (mapcar 'foo *teststrs*))


;;yandex-images-download Firefox --keywords "vodka, bears, balalaika" --limit 10

(alexandria:define-constant +mask+ "[MASK]" :test #'string=)
(defun test1 (&optional (a +mask+) (b +mask+) (c +mask+))
  (let ((thing (format nil
		    ;;"When you combine ~a and ~a you get ~a."
		    "Combining ~a and ~a produces ~a."
		    a b c)))
    (write-string thing)
    (car (foo thing))))

(defun mask (n)
  (with-output-to-string (str)
    (loop :repeat n :do
       (write-string +mask+ str))))

(defun onlymasks ()
  (let ((thing (results)))
    (setf thing (coerce thing 'list))
    (let ((input (first thing))
	  (rest (cdr thing))
	  (mask (getf (mask-id) :mask)))
      (mapcar (lambda (item)
		(remove nil
			(map 'list
			     (lambda (a b c d)
			       (declare (ignorable a))
			       (when (= b mask)
				 (list c d)))
			     (aref input 0)
			     (aref input 1)
			     (aref item 0)
			     (aref item 1))))
	      rest))))