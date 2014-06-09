<?php 
/**
* Some basic functions for locating tags within the document.
* TODO: make them more robust.
* NB: having these here allows us to adapt to document structurs
* that may not parse otherwise. 
*/

/**
* Find the first tag $tag after $start position in $content.
* 
* @param string $content This is the source string in which to look.
* @param string $tag This is the tag name to find.
* @param int $start The position within the source string to begin searching; 
*           defaults to 0, the beginning of the string.
*
* @return int The boolean false (0) value if the tag is not found.
* @return array The offset capture if the tag was found. The first element contains
*                  the matched string, the second the position of the start of the 
*                  match in the source string, the third is the position of the end of
*                  the match.
*/
function findTagBegin($content, $tag, $start=0) {
  preg_match('/<'.$tag.'[^>]*>/', $content, $matches, PREG_OFFSET_CAPTURE, $start);
  if (count($matches) == 0) {
    return 0;
  }
  array_push($matches[0], $matches[0][1]+strlen($matches[0][0]));
  return $matches[0]; 
}

/**
* Finds the ending tag defined by the tag name within a give source string.
*
* This function assumes that it is being searched after the opening tag. This allows it 
* to pass through embedded instances of the same tag.
*
* @param string $content This is the source string in which to look.
* @param string $tag This is the tag name to find.
* @param int $start The position within the source string to begin searching; 
*           defaults to 0, the beginning of the string.
*
* @return int The boolean false (0) value if the tag is not found.
* @return array The offset capture if the tag was found. The first element contains
*                  the matched string, the second the position of the start of the 
*                  match in the source string, the third is the position of the end of
*                  the match.
*/
function findTagEnd($s, $tag, $start=0) {
  $nestCount = 0;
  do {
    preg_match('/(:?(?P<tagend><\/'.$tag.'>)|(?P<tagbegin><'.$tag.'))/', $s, $matches, PREG_OFFSET_CAPTURE, $start);
    if (count($matches) > 0) {
      if ($matches['tagend'][1] > $start) {
        if ($nestCount-- == 0) { 
          array_push($matches['tagend'], $matches['tagend'][1] + strlen($matches['tagend'][0]));
          return $matches['tagend'];
        } else {
         $start = $matches['tagend'][1] + strlen($matches['tagend'][0]); 
        }
      } elseif ($matches['tagbegin'][1] > $start) {
        $nestCount++;
        $start = $matches['tagbegin'][1] + 1;
        continue; 
      }
    }
  } while (count($matches) > 0);
  return 0;
}
